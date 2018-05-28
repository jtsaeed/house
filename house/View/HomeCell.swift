//
//  HomeCell.swift
//  house
//
//  Created by James Saeed on 28/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit

class HomeCell: UITableViewCell {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    func configure(mainText: String, secondaryText: String, amount: Int) {
        mainLabel.text = mainText
        secondaryLabel.text = secondaryText
        amountLabel.text = "\(amount)"
    }
}
