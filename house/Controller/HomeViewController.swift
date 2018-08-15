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
    
    var choresAmount = 0
    var debtsAmount = 0
    var shoppingItemsAmount = 0

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        addTableViewPadding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setNavigationTitle()
        getData()
    }
    
    @IBAction func moreButtonPressed(_ sender: Any) {
        presentMoreActionSheet(sender)
    }
}

// MARK: - Table View

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell") as? HomeCell else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            cell.configure(mainText: "There \(choresAmount == 1 ? "is" : "are")", secondaryText: "\(choresAmount == 1 ? "chore" : "chores") remaining", amount: choresAmount)
        } else if indexPath.row == 1 {
            cell.configure(mainText: "You have", secondaryText: "outstanding \(debtsAmount == 1 ? "debt" : "debts")", amount: debtsAmount)
        } else if indexPath.row == 2 {
            cell.configure(mainText: "There \(shoppingItemsAmount == 1 ? "is" : "are")", secondaryText: "\(shoppingItemsAmount == 1 ? "item" : "items") on the shoppping list", amount: shoppingItemsAmount)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tabBarController?.selectedIndex = (indexPath.row + 1)
    }
}

// MARK: - Action Sheet

extension HomeViewController {
    
    private func presentMoreActionSheet(_ sender: Any) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            self.signOut()
        })
        sheet.addAction(UIAlertAction(title: "Leave House", style: .destructive) { (action) in
            self.presentLeaveHouseAlert()
        })
        sheet.addAction(UIAlertAction(title: "Show House Info", style: .default) { (action) in
            self.presentHouseInfoAlert()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            sheet.dismiss(animated: true, completion: nil)
        })
        
        if let popoverController = sheet.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        present(sheet, animated: true, completion: nil)
    }
    
    private func presentLeaveHouseAlert() {
        let alert = UIAlertController(title: "Leave house", message: "Are you sure you would like to leave this house?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            DataService.instance.leaveHouse()
            self.signOut()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentHouseInfoAlert() {
        DataService.instance.getHouseInfo { (name, code) in
            let alert = UIAlertController(title: "House Info", message: "Name: \(name)\nCode: \(code)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Util

extension HomeViewController {
    
    private func addTableViewPadding() {
        tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
    
    private func getData() {
        DataService.instance.getAmountOfChores { (pulledAmount) in
            self.choresAmount = pulledAmount
            self.tableView.reloadData()
        }
        
        DataService.instance.getAmountOfOutstandingDebts { (pulledAmount) in
            self.debtsAmount = pulledAmount
            self.tableView.reloadData()
        }
        
        DataService.instance.getAmountOfShoppingItems { (pulledAmount) in
            self.shoppingItemsAmount = pulledAmount
            self.tableView.reloadData()
        }
    }
    
    private func setNavigationTitle() {
        DataService.instance.getCurrentUserNickname { (nickname) in
            self.navigationItem.title = "Hello \(nickname)!"
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "signOut", sender: nil)
        } catch {
            Util.instance.presentErrorDialog(withMessage: .signOutFailed, context: self)
        }
    }
}
