//
//  Chore.swift
//  house
//
//  Created by James Saeed on 19/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import Foundation

struct Shopping {
    let shoppingId: String
    
    let content: String
    let author: String
    let date: Date
    
    func clearItem() {
        DataService.instance.deleteShoppingItem(with: shoppingId)
    }
}
