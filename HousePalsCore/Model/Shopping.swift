//
//  Chore.swift
//  house
//
//  Created by James Saeed on 19/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import Foundation

public struct Shopping {
    
    let shoppingId: String
    
    public let content: String
    public let author: String
    
    public func clearItem() {
        DataService.instance.deleteShoppingItem(with: shoppingId)
    }
}
