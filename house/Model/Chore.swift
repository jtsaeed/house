//
//  Chore.swift
//  house
//
//  Created by James Saeed on 19/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import Foundation
import SwiftDate

struct Chore {
    let choreId: String
    
    let content: String
    let author: String
    let date: String
    
    func clearChore() {
        DataService.instance.deleteChore(with: choreId)
    }
    
    func getDateText() -> String {
        guard let parsedDate = date.toDate() else { return "" }
        
        let days = Date().day - parsedDate.day
        
        if days == 0 {
            return "today"
        } else if days == 1 {
            return "yesterday"
        } else {
            return "\(days) days ago"
        }
    }
}
