//
//  LogInViewController.swift
//  CodeBuddy
//
//  Created by Omar Tehsin on 2019-06-15.
//  Copyright © 2019 Omar Tehsin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

var spinnerView = SpinnerViewController()

class LogInViewController: UIViewController {
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    enum LogInError: Error {
        case incompleteForm
        case invalidEmail
        case incorrectPassword
    }
    

    @IBAction func logInButtonPressed(_ sender: Any) {
    }
    
    func handleLogIn() {
        guard let email = emailText.text, let password = passwordText.text else {
            print("form is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, link: password) { (user, error) in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .userNotFound:
                        Alert.showIncorrectEmailAlert(on: self)
                    case .wrongPassword:
                        Alert.showInvalidPasswordAlert(on: self)
                    case .missingEmail:
                        Alert.showIncompleteFormAlert(on: self)
                    default:
                        Alert.showUnableToRetrieveDataAlert(on: self)
                    }
                }
                return
            } else {
                self.performSegue(withIdentifier: "goToMainFromLogIn", sender: self)
                print("Success")
            }
        }
    }

}
