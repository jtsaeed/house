//
//  DebtCell.swift
//  house
//
//  Created by James Saeed on 22/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import SwipeCellKit

class DebtCell: SwipeTableViewCell {
    
    private var isPressed: Bool = false
    private var longPressGestureRecognizer: UILongPressGestureRecognizer? = nil
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var roundedAccent: UIViewX!
    @IBOutlet weak var squareAccent: UIViewX!
    
    func configure(with debt: Debt) {
        if debt.isPaying {
            typeLabel.text = "You owe"
            setDetailLabel(withDescription: "to", subject: debt.receiverId, and: debt.reason)
            setAccent(with: UIColor(red:1.00, green:0.23, blue:0.19, alpha:1.0))
        } else {
            typeLabel.text = "You're owed"
            setDetailLabel(withDescription: "from", subject: debt.payerId, and: debt.reason)
            setAccent(with: UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0))
        }
        
        amountLabel.text = "£\(debt.amount)"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureGestureRecognizer()
    }
    
    private func setDetailLabel(withDescription description: String, subject id: String, and reason: String) {
        DataService.instance.getUserNickname(for: id) { (nickname) in
            self.detailLabel.text = "\(description) \(nickname) for \(reason)"
        }
    }
    
    private func setAccent(with color: UIColor) {
        roundedAccent.backgroundColor = color
        squareAccent.backgroundColor = color
    }
}


/*
 GESTURE
 ANIMATIONS
 */
extension DebtCell {
    
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
