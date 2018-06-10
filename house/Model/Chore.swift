//
//  Chore.swift
//  house
//
//  Created by James Saeed on 19/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import Foundation

struct Chore {
    let choreId: String
    
    let content: String
    let author: String
    
    func clearChore() {
        DataService.instance.deleteChore(with: choreId)
    }
}
