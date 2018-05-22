//
//  DebtsViewController.swift
//  house
//
//  Created by James Saeed on 20/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import Firebase

class MoneyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func addButtonPressed(_ sender: Any) {
        presentAddNewDebtDialog()
    }
}

extension MoneyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "debtCell") else {
            return UITableViewCell()
        }
        
        return cell
    }
}

/*
 UTIL
 */
extension MoneyViewController {
    private func presentAddNewDebtDialog() {
        let alert = UIAlertController(title: "Enter debt details", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "For person..."
        }
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "With reason..."
        }
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "For amount..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            guard let receiverId = Auth.auth().currentUser?.uid else { return }
            guard let payerId = alert.textFields?[0].text else { return }
            guard let reason = alert.textFields?[1].text else { return }
            guard let amountString = alert.textFields?[2].text else { return }
            guard let amount = Int(amountString) else { return }
            
            DataService.instance.createDebt(from: receiverId, for: payerId, with: amount, and: reason)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
