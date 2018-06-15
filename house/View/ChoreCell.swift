//
//  ChoreCell.swift
//  house
//
//  Created by James Saeed on 20/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import SwipeCellKit

class ChoreCell: SwipeTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func configure(with chore: Chore) {
        titleLabel.text = chore.content
        
        DataService.instance.getUserNickname(for: chore.author) { (nickname) in
            self.subtitleLabel.text = "added by \(nickname)"
        }
    }
}
