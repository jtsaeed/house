//
//  ChoreCell.swift
//  house
//
//  Created by James Saeed on 20/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit

class ChoreCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
