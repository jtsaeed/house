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
    @IBOutlet weak var noChoresIndicator: UILabel!
    
    var chores = [Chore]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTableViewPadding()
        loadChores()
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
extension ChoresViewController: UITableViewDelegate, UITableViewDataSource {
    
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
 TABLEVIEW
 SWIPES
 */
extension ChoresViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let clearAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
            self.clearChore(at: indexPath)
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
extension ChoresViewController {
    
    private func addTableViewPadding() {
        tableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 16, right: 0)
    }
    
    private func loadChores() {
        DataService.instance.getChores { (pulledChores) in
            if pulledChores.isEmpty {
                self.noChoresIndicator.isHidden = false
            } else {
                self.noChoresIndicator.isHidden = true
                self.chores = pulledChores
                self.tableView.reloadData()
            }
        }
    }
    
    private func clearChore(at indexPath: IndexPath) {
        chores[indexPath.row].clearChore()
        chores.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.reloadData()
        Util.instance.generateClearFeedback()
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
            if let choreContent = alert.textFields?.first?.text {
                DataService.instance.createChore(with: choreContent)
                self.loadChores()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
