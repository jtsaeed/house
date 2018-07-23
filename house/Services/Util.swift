//
//  Util.swift
//  house
//
//  Created by James Saeed on 20/06/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit

class Util {
    
    static let instance = Util()
    
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    func presentErrorDialog(withMessage message: ErrorMessage, context view: UIViewController) {
        notificationFeedbackGenerator.notificationOccurred(.error)
        
        let alert = UIAlertController(title: "Error", message: message.rawValue, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        view.present(alert, animated: true, completion: nil)
    }
    
    func generateClearFeedback() {
        notificationFeedbackGenerator.notificationOccurred(.success)
    }
    
    func saveUserInfo(for user: User) {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(user.name, forKey: "name")
        userDefaults.set(user.nickname, forKey: "nickname")
        userDefaults.set(user.email, forKey: "email")
        userDefaults.set(user.userId, forKey: "userId")
        userDefaults.set(user.houseId, forKey: "houseId")
    }
    
    func clearUserInfo() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}

enum ErrorMessage: String {
    
    case currentUserFailed = "Unable to retrieve the currently signed in user for unknown reasons"
    case signOutFailed = "Sign out failed for unknown reasons"
    
    case houseNameInvalid = "Please enter a valid house name"
    case houseCodeInvalid = "Please enter a valid house code within 4 to 12 digits"
    case houseNicknameInvalid = "Please enter a valid nickname or first name"
    
    case houseNameTaken = "That house name is unfortunately already taken, please enter a unique house name"
    
    case debtAmountInvalid = "Failed to edit debt due to an invalid debt amount, please enter a whole number"
    
}
