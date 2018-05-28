//
//  LoginViewController.swift
//  house
//
//  Created by James Saeed on 19/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        if let email = emailField.text {
            if let password = passwordField.text {
                AuthService.instance.loginUser(with: email, and: password) { (success, error) in
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        // TODO: Proper error handler
                        print(String(describing: error?.localizedDescription))
                    }
                }
            }
        }
    }
}
