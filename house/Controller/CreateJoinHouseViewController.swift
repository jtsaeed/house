//
//  CreateJoinHouseViewController.swift
//  house
//
//  Created by James Saeed on 12/07/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import Firebase

class CreateJoinHouseViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameField: UITextFieldX!
    @IBOutlet weak var codeField: UITextFieldX!
    @IBOutlet weak var nicknameField: UITextFieldX!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        createHouse()
    }
}

extension CreateJoinHouseViewController {
    
    private func createHouse() {
        validateFields { (houseName, houseCode, nickname) in
            DataService.instance.createHouse(houseName, houseCode, nickname, handler: {
                DataService.instance.joinHouse(houseName, houseCode, nickname, handler: {
                    self.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
    
    private func validateFields(createHouse: @escaping (_ houseName: String, _ houseCode: String, _ nickname: String) -> ()) {
        guard let houseName = nameField.text else {
            Util.instance.presentErrorDialog(withMessage: "house name", context: self)
            return
        }
        
        guard let houseCode = codeField.text else {
            Util.instance.presentErrorDialog(withMessage: "house code", context: self)
            return
        }
        
        let nickname = nicknameField.text ?? ""
        
        createHouse(houseName, houseCode, nickname)
    }
}
