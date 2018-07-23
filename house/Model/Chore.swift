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
    let date: Date
    
    func clearChore() {
        DataService.instance.deleteChore(with: choreId)
    }
}
