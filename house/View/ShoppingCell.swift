//
//  ShoppingCell.swift
//  house
//
//  Created by James Saeed on 10/06/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import SwipeCellKit

class ShoppingCell: SwipeTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func configure(with shoppingItem: Shopping) {
        titleLabel.text = shoppingItem.content
        
        DataService.instance.getUserNickname(for: shoppingItem.author) { (nickname) in
            self.subtitleLabel.text = "added by \(nickname)"
        }
    }
}
