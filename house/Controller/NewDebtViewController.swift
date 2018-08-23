//
//  NewDebtViewController.swift
//  house
//
//  Created by James Saeed on 22/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import Firebase
import Eureka

class NewDebtViewController: FormViewController {

    var people = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataService.instance.getUsersNameIdPair { (pulledPairs) in
            if pulledPairs.isEmpty {
                self.presentEmptyHouseDialog()
            } else {
                self.people = pulledPairs
                self.createForm()
            }
        }
    }

    private func createForm() {
        form +++ Section("Create a debt for...")
            <<< PickerRow<String>() { row in
                row.title = "Who?"
                row.options = Array(self.people.keys)
                row.tag = "payerName"
                row.value = Array(self.people.keys)[0]
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
                row.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                })
                row.onCellSelection({ (cell, row) in
                    self.doneButtonPressed()
                })
        }
        
        self.tableView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
    }
}

/*
 UTIL
 */
extension NewDebtViewController {
    
    private func doneButtonPressed() {
        guard let payerNameRow: PickerRow<String> = form.rowBy(tag: "payerName") else { return }
        guard let payerName = payerNameRow.value else { return }
        guard let payer = self.people[payerName] else { return }
        
        guard let reasonRow: TextRow = form.rowBy(tag: "reason") else { return }
        guard let reason = reasonRow.value else { return }
        
        guard let amountRow: IntRow = form.rowBy(tag: "amount") else { return }
        guard let amount = amountRow.value else { return }
        
        DataService.instance.createDebt(for: payer, with: amount, and: reason)
        
        navigationController?.popViewController(animated: true)
    }
    
    private func presentEmptyHouseDialog() {
        self.navigationController?.popViewController(animated: true)
        Util.instance.presentErrorDialog(withMessage: .debtParticipantsInvalid, context: self)
    }
}
