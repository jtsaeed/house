//
//  ShoppingViewController.swift
//  house
//
//  Created by James Saeed on 10/06/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import SwipeCellKit

class ShoppingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var shoppingItems = [Shopping]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadShoppingItems()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        presentAddNewShoppingItemDialog()
    }
}

/*
 TABLEVIEW
 */
extension ShoppingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingCell") as? ShoppingCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        
        let shoppingItem = shoppingItems[indexPath.row]
        cell.configure(with: shoppingItem)
        
        return cell
    }
}

extension ShoppingViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let clearAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
            self.clearShoppingItem(at: indexPath)
        }
        clearAction.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        clearAction.highlightedBackgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        clearAction.image = #imageLiteral(resourceName: "ClearCell")
        
        return [clearAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.transitionStyle = .drag
        return options
    }
}

/*
 UTIL
 */
extension ShoppingViewController {
    
    private func loadShoppingItems() {
        DataService.instance.getShoppingItems { (pulledShoppingItems) in
            self.shoppingItems = pulledShoppingItems
            self.tableView.reloadData()
        }
    }
    
    private func clearShoppingItem(at indexPath: IndexPath) {
        shoppingItems[indexPath.row].clearItem()
        shoppingItems.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.reloadData()
        Util.instance.generateClearFeedback()
    }
    
    private func presentAddNewShoppingItemDialog() {
        let alert = UIAlertController(title: "What shopping item?", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Type here..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let shoppingItemName = alert.textFields?.first?.text {
                DataService.instance.createShoppingItem(with: shoppingItemName)
                self.loadShoppingItems()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
