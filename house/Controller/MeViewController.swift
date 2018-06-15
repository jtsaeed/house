//
//  MeViewController.swift
//  house
//
//  Created by James Saeed on 28/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import Firebase

class MeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setNavigationTitle()
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "signOut", sender: nil)
        } catch let signOutError as NSError {
            // TODO: Comprehensive Error
        }
        
    }
}

/*
 UTIL
 */
extension MeViewController {
    private func setNavigationTitle() {
        DataService.instance.getUserData { (user) in
            self.navigationItem.title = user.name
        }
    }
}
