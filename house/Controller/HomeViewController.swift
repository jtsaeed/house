//
//  FirstViewController.swift
//  house
//
//  Created by James Saeed on 09/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitle()
    }
    
    
}

/*
 TABLE VIEW
 */
extension HomeViewController {
    
}

/*
 UTIL
 */
extension HomeViewController {
    private func setNavigationTitle() {
        DataService.instance.getUser { (user) in
            self.navigationItem.title = "Hello \(user.nickname)!"
        }
    }
}
