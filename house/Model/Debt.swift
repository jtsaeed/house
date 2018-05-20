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
    
    let reciverId: String
    let payerId: String
    var value: Int
    
    mutating func decrease(by amount: Int) {
        value -= amount
    }
    
    mutating func increase(by amount: Int) {
        value += amount
    }
}
