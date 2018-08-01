//
//  Extensions.swift
//  house
//
//  Created by James Saeed on 01/08/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
