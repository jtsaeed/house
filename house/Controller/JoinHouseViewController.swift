//
//  JoinHouseViewController.swift
//  house
//
//  Created by James Saeed on 05/06/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit

class JoinHouseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func createHousePressed(_ sender: Any) {
        
    }
    
    @IBAction func joinHousePressed(_ sender: Any) {
        presentJoinHouseDialog()
    }
    
    private func presentJoinHouseDialog() {
        let alert = UIAlertController(title: "Join a house", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Enter the house name..."
        }
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Enter the house code..."
        }
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Enter your nickname..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let houseName = alert.textFields?[0].text {
                if let houseCode = alert.textFields?[1].text {
                    if let nickname = alert.textFields?[2].text {
                        DataService.instance.validateHouseRequest(with: houseName, and: houseCode, handler: { (houseId) in
                            if let houseId = houseId {
                                DataService.instance.joinHouse(with: houseId, and: nickname, handler: {
                                    self.dismiss(animated: true, completion: nil)
                                })
                            }
                        })
                    }
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
