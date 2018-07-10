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
    
    func presentErrorDialog(withMessage message: String, context view: UIViewController) {
        notificationFeedbackGenerator.notificationOccurred(.error)
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        view.present(alert, animated: true, completion: nil)
    }
    
    func generateClearFeedback() {
        notificationFeedbackGenerator.notificationOccurred(.success)
    }
}
