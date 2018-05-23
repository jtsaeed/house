//
//  Debt.swift
//  house
//
//  Created by James Saeed on 19/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import Foundation

struct Debt {
    let debtId: String
    
    let isPaying: Bool
    let receiverId: String
    let payerId: String
    let reason: String
    var amount: Int
    
    mutating func decrease(by amount: Int) {
        self.amount -= amount
    }
    
    mutating func increase(by amount: Int) {
        self.amount += amount
    }
}
