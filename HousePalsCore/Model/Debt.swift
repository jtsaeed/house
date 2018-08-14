//
//  Debt.swift
//  house
//
//  Created by James Saeed on 19/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import Foundation

public struct Debt {
    
    let debtId: String
    
    public let isPaying: Bool
    public let receiverId: String
    public let payerId: String
    public let reason: String
    public var amount: Int
    
    public func clearDebt() {
        DataService.instance.deleteDebt(with: debtId)
    }
    
    public mutating func changeAmount(with newAmount: Int) {
        self.amount = newAmount
        
        DataService.instance.changeDebtAmount(for: debtId, with: newAmount)
    }
}
