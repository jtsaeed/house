//
//  DebtsViewController.swift
//  house
//
//  Created by James Saeed on 20/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import Firebase
//import SwipeCellKit

class MoneyViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noDebtsIndicator: UILabel!
    var debts = [Debt]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTableViewPadding()
        loadDebts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadDebts()
    }
}

/*
 TABLEVIEW
 */
extension MoneyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "debtCell") as? DebtCell else {
            return UITableViewCell()
        }
//        cell.delegate = self
        
        let debt = debts[indexPath.row]
        cell.configure(with: debt)
        
        return cell
    }
}

/*
 TABLEVIEW
 SWIPES
extension MoneyViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let clearAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
            self.clearDebt(at: indexPath)
        }
        clearAction.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        clearAction.highlightedBackgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        clearAction.image = #imageLiteral(resourceName: "ClearCell")
        
        let editAction = SwipeAction(style: .default, title: nil) { (action, indexPath) in
            self.presentEditDebtDialog(for: indexPath.row)
        }
        editAction.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        editAction.highlightedBackgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        editAction.image = #imageLiteral(resourceName: "EditCell")
        
        return [clearAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.transitionStyle = .drag
        return options
    }
}
 */

/*
 UTIL
 */
extension MoneyViewController {
    
    private func addTableViewPadding() {
        tableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
    }
    
    private func loadDebts() {
        DataService.instance.getDebts { (pulledDebts) in
            if pulledDebts.isEmpty {
                self.noDebtsIndicator.isHidden = true
            } else {
                self.noDebtsIndicator.isHidden = false
                self.debts = pulledDebts
                self.tableView.reloadData()
            }
        }
    }
    
    private func clearDebt(at indexPath: IndexPath) {
        debts[indexPath.row].clearDebt()
        debts.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.reloadData()
        Util.instance.generateClearFeedback()
    }
    
    private func presentEditDebtDialog(for index: Int) {
        let alert = UIAlertController(title: "Enter new amount", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "amount"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            guard let newAmountString = alert.textFields?[0].text else { return }
            if let newAmount = Int(newAmountString) {
                self.debts[index].changeAmount(with: newAmount)
                self.tableView.reloadData()
            } else {
                alert.dismiss(animated: true, completion: nil)
                Util.instance.presentErrorDialog(withMessage: .debtAmountInvalid, context: self)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
