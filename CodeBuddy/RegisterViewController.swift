//
//  ViewController.swift
//  CodeBuddy
//
//  Created by Omar Tehsin on 2019-06-15.
//  Copyright © 2019 Omar Tehsin. All rights reserved.
// Find a buddy to code with. Proudly built in Toronto.

import UIKit
import Firebase
import FirebaseAuth


class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    
    
    @IBOutlet weak var defaultUserImage: UIImageView!
    var ref: DatabaseReference!
    var registeredUsers = [Users]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultUserImage.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    
    //MARK: Image Picker
    
    @IBAction func imageTapped(_ sender: Any) {
        changeImage()
    }
    
    
    
    
    func changeImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            defaultUserImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: User Registration

    @IBAction func registerBtnPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .emailAlreadyInUse:
                        Alert.showEmailAlreadyInUseAlert(on: self)
                    case .weakPassword:
                        Alert.showWeakPasswordAlert(on: self)
                    case .invalidEmail:
                        Alert.showInvalidEmailAlert(on: self)
                    case .missingEmail:
                        Alert.showIncompleteFormAlert(on: self)
                    default:
                        Alert.showUnableToRetrieveDataAlert(on: self)
                    }
                }
                return
            }
            guard let uid = user?.user.uid else {return}
            self.ref = Database.database().reference()
            self.ref.child("users").child(uid).setValue(["friends": self.registeredUsers])
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("\(imageName).png")
            
            if let uploadData = self.defaultUserImage.image?.pngData() {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    storageRef.downloadURL(completion: { (url, err) in
                        if (err == nil) {
                            if let downloadURL = url {
                                let downloadString = downloadURL.absoluteString
                                let values = ["email": email, "profileImageURL": downloadString, "uid": uid, "nameofUser": name]
                                self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String: AnyObject])
                                
                            }
                        }
                    })
                })
            }
            self.performSegue(withIdentifier: "goToMain", sender: self)
        }
        
    }
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference(fromURL: "https://codebuddy-670ef.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values) { (err, ref) in
            if err != nil {
                print(err)
                return
            }
            print("Saved user successfully into firebase db")
        }
    }
    
}

