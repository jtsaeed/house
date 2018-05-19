//
//  AuthService.swift
//  house
//
//  Created by James Saeed on 19/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthService {
    static let instance = AuthService()
    
    func loginUser(with email: String, and password: String, loginComplete: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if user == nil {
                loginComplete(false, error)
                return
            } else {
                loginComplete(true, nil)
            }
        }
    }
}
