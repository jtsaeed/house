//
//  NewDebtViewController.swift
//  house
//
//  Created by James Saeed on 22/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import Eureka
import Firebase

class NewDebtViewController: FormViewController {

    var people = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataService.instance.getUsersNicknameIdPair { (pulledPairs) in
            self.people = pulledPairs
            self.createForm()
        }
    }

    private func createForm() {
        form +++ Section("Create a debt for...")
            <<< PickerRow<String>() { row in
                row.title = "Who?"
                row.options = Array(self.people.keys)
                row.tag = "payerName"
            }
            <<< TextRow() { row in
                row.title = "What for?"
                row.placeholder = "Enter reason here"
                row.tag = "reason"
            }
            <<< IntRow() { row in
                row.title = "For how much?"
                row.placeholder = "Enter amount here"
                row.tag = "amount"
            }
            +++ Section("")
            <<< ButtonRow() { row in
                row.title = "Done"
                row.onCellSelection({ (cell, button) in
                    self.doneButtonPressed()
                })
        }
    }
}

/*
 UTIL
 */
extension NewDebtViewController {
    private func doneButtonPressed() {
        guard let receiverId = Auth.auth().currentUser?.uid else { return }
        
        guard let payerNameRow: PickerRow<String> = form.rowBy(tag: "payerName") else { return }
        guard let payerName = payerNameRow.value else { return }
        guard let payerId = self.people[payerName] else { return }
        
        guard let reasonRow: TextRow = form.rowBy(tag: "reason") else { return }
        guard let reason = reasonRow.value?.lowercased() else { return }
        
        guard let amountRow: IntRow = form.rowBy(tag: "amount") else { return }
        guard let amount = amountRow.value else { return }
        
        DataService.instance.createDebt(from: receiverId, for: payerId, with: amount, and: reason)
        
        navigationController?.popViewController(animated: true)
    }
}
