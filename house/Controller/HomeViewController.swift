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
        
        tableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setNavigationTitle()
        clearIconBadge()
        getData()
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        signOut()
    }
}

/*
 TABLE VIEW
 */
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell") as? HomeCell else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            cell.configure(mainText: "There are", secondaryText: "chores remaining", amount: choresAmount)
        } else if indexPath.row == 1 {
            cell.configure(mainText: "You have", secondaryText: "outstanding debts", amount: debtsAmount)
        } else if indexPath.row == 2 {
            cell.configure(mainText: "There are", secondaryText: "items on the shoppping list", amount: shoppingItemsAmount)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tabBarController?.selectedIndex = (indexPath.row + 1)
    }
}

/*
 UTIL
 */
extension HomeViewController {
    
    private func setNavigationTitle() {
        DataService.instance.getCurrentUserNickname { (nickname) in
            self.navigationItem.title = "Hello \(nickname)!"
        }
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
    
    private func clearIconBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "signOut", sender: nil)
        } catch let signOutError as NSError {
            Util.instance.presentErrorDialog(withMessage: signOutError.localizedDescription, context: self)
        }
    }
}
