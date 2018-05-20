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

    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "What chore?", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Type here..."
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let choreName = alert.textFields?.first?.text {
                DataService.instance.createChore(withContent: choreName)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension ChoresViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}
