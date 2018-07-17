//
//  JoinHouseViewController.swift
//  house
//
//  Created by James Saeed on 05/06/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit

class PrepareHouseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createJoinHouseVC = segue.destination as? CreateJoinHouseViewController {
            createJoinHouseVC.isJoining = (segue.identifier == "joinHouse")
        }
    }
}
