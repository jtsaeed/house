//
//  SecondViewController.swift
//  house
//
//  Created by James Saeed on 09/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit

class ChoresViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var chores = [Chore]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        let chore = chores[indexPath.row]
        cell.configure(with: chore.content)
        
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
