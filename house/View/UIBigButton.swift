//
//  DesignableButton.swift
//  SkyApp
//
//  Created by Mark Moeykens on 12/18/16.
//  Copyright © 2016 Mark Moeykens. All rights reserved.
//

import UIKit

@IBDesignable
class UIButtonX: UIButton {
    
    override func draw(_ rect: CGRect) {
        self.clipsToBounds = true
        
        layer.cornerRadius = 10
    }
}
