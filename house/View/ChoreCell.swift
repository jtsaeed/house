//
//  ChoreCell.swift
//  house
//
//  Created by James Saeed on 20/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import SwipeCellKit

class ChoreCell: SwipeTableViewCell {
    
    private var isPressed: Bool = false
    private var longPressGestureRecognizer: UILongPressGestureRecognizer? = nil

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func configure(with chore: Chore) {
        titleLabel.text = chore.content.lowercased()
        
        DataService.instance.getUserNickname(for: chore.author) { (nickname) in
            self.subtitleLabel.text = "added by \(nickname)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureGestureRecognizer()
    }
}

/*
 GESTURE
 ANIMATIONS
 */
extension ChoreCell {
    
    private func configureGestureRecognizer() {
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gestureRecognizer:)))
        longPressGestureRecognizer?.minimumPressDuration = 0.1
        addGestureRecognizer(longPressGestureRecognizer!)
    }
    
    @objc internal func handleLongPressGesture(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            handleLongPressBegan()
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            handleLongPressEnded()
        }
    }
    
    private func handleLongPressBegan() {
        guard !isPressed else {
            return
        }
        
        UIImpactFeedbackGenerator().impactOccurred()
        isPressed = true
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        })
    }
    
    private func handleLongPressEnded() {
        guard isPressed else {
            return
        }
        
        UIImpactFeedbackGenerator().impactOccurred()
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform.identity
        }) { (finished) in
            self.isPressed = false
        }
    }
}
