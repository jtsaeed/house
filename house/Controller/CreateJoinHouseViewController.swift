//
//  CreateJoinHouseViewController.swift
//  house
//
//  Created by James Saeed on 12/07/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class CreateJoinHouseViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameField: UITextFieldX!
    @IBOutlet weak var codeField: UITextFieldX!
    @IBOutlet weak var nicknameField: UITextFieldX!
    
    var isJoining: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
    
        guard let isJoining = isJoining else { return }
        
        if isJoining {
            setJoiningFieldNames()
        }
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        guard let isJoining = isJoining else { return }
        
        if isJoining {
            joinHouse()
        } else {
            createHouse()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Text Fields

extension CreateJoinHouseViewController: UITextFieldDelegate {
    
    private func setDelegates() {
        nameField.delegate = self
        codeField.delegate = self
        nicknameField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            nameField.resignFirstResponder()
            codeField.becomeFirstResponder()
        } else if textField == codeField {
            codeField.resignFirstResponder()
            nicknameField.becomeFirstResponder()
        } else {
            nicknameField.resignFirstResponder()
        }
        return false
    }
    
    private func validateFields(createHouse: @escaping (_ houseName: String, _ houseCode: String, _ nickname: String) -> ()) {
        if let houseName = nameField.text, !houseName.isEmpty {
            if let houseCode = codeField.text, houseCode.count >= 4 && houseCode.count <= 12 {
                if let nickname = nicknameField.text, !nickname.isEmpty {
                    createHouse(houseName, houseCode, nickname)
                } else {
                    Util.instance.presentErrorDialog(withMessage: .houseNicknameInvalid, context: self)
                }
            } else {
                Util.instance.presentErrorDialog(withMessage: .houseCodeInvalid, context: self)
            }
        } else {
            Util.instance.presentErrorDialog(withMessage: .houseNameInvalid, context: self)
        }
    }
}

// MARK: - Util

extension CreateJoinHouseViewController {
    
    private func setJoiningFieldNames() {
        titleLabel.text = "Join an existing house"
        nameField.placeholder = "Enter the name of the house"
        codeField.placeholder = "Enter the code for the house"
    }
    
    private func joinHouse() {
        validateFields { (houseName, houseCode, nickname) in
            DataService.instance.joinHouse(houseName, houseCode, nickname, completion: { (success) in
                if success {
                    print("HELLOOOOOOOO")
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    self.notificationsSetup()
                } else {
                    Util.instance.presentErrorDialog(withMessage: .houseFailedValidation, context: self)
                }
            })
        }
    }
    
    private func createHouse() {
        validateFields { (houseName, houseCode, nickname) in
            DataService.instance.checkIfHouseExists(houseName, completion: { (exists) in
                if !exists {
                    DataService.instance.createHouse(houseName, houseCode, completion: {
                        DataService.instance.joinHouse(houseName, houseCode, nickname, completion: {  (success) in self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            self.notificationsSetup()
                        })
                    })
                } else {
                    Util.instance.presentErrorDialog(withMessage: .houseNameTaken, context: self)
                }
            })
        }
    }

    private func notificationsSetup() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (_, _) in }
        UIApplication.shared.registerForRemoteNotifications()
    }
}
