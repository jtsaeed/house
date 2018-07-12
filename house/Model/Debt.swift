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
    
    func clearDebt() {
        DataService.instance.deleteDebt(with: debtId)
    }
    
    mutating func changeAmount(with newAmount: Int) {
        self.amount = newAmount
        
        DataService.instance.changeDebtAmount(for: debtId, with: newAmount)
    }
}
