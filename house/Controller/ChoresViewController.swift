//
//  SecondViewController.swift
//  house
//
//  Created by James Saeed on 09/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import SwipeCellKit

class ChoresViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var chores = [Chore]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadChores()
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        presentAddNewChoreDialog()
    }
}

/*
 TABLEVIEW
 */
extension ChoresViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let clearAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
            // DO THINGS
        }
        clearAction.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        clearAction.highlightedBackgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        clearAction.image = #imageLiteral(resourceName: "ClearCell")
        
        return [clearAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        //        options.expansionStyle = .destructive
        options.transitionStyle = .drag
        return options
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "choreCell") as? ChoreCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        
        let chore = chores[indexPath.row]
        cell.configure(with: chore)
        
        return cell
    }
}

/*
 UTIL
 */
extension ChoresViewController {
    
    private func loadChores() {
        DataService.instance.getChores { (pulledChores) in
            self.chores = pulledChores
            self.tableView.reloadData()
        }
    }
    
    private func presentAddNewChoreDialog() {
        let alert = UIAlertController(title: "What chore?", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Type here..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let choreName = alert.textFields?.first?.text {
                DataService.instance.createChore(with: choreName)
                self.loadChores()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
