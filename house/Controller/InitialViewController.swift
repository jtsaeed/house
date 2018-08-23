//
//  InitialViewController.swift
//  house
//
//  Created by James Saeed on 28/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import FirebaseUI

class InitialViewController: UIViewController, FUIAuthDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DataService.instance.checkIfUserRegistered { (registered) in
            if registered {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        let authViewController = authUI?.authViewController()
        present(authViewController!, animated: true, completion: nil)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if authDataResult != nil {
            DataService.instance.checkIfUserRegistered { (registered) in
                if !registered {
                    let prepareHouseVC = self.storyboard?.instantiateViewController(withIdentifier: "PrepareHouseViewController")
                    self.present(prepareHouseVC!, animated: true, completion: nil)
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
