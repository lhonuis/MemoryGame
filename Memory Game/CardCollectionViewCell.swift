//
//  CardCollectionViewCell.swift
//  Memory Game
//
//  Created by Louis Hon on 22/11/2019.
//  Copyright © 2019 Louis Hon. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var frontImageView: UIImageView! {
        didSet {
            self.layer.cornerRadius = 10.0
        }
    }
    
    @IBOutlet var backImageView: UIImageView! {
        didSet {
            self.layer.cornerRadius = 10.0
        }
    }
    
    var card: Card?
    
    func setCard(_ card: Card) {
        
        self.card = card
        frontImageView.image = UIImage(named: card.imageName)
        
        if card.isMatched {
            backImageView.alpha = 0
            frontImageView.alpha = 0
            return
        } else {
            backImageView.alpha = 1
            frontImageView.alpha = 1
        }
        
        // Determine whether the card is flipped up or flipped down
        if card.isFlipped {
            UIView.transition(from: backImageView, to: frontImageView, duration: 0, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
        } else {
            UIView.transition(from: frontImageView, to: backImageView, duration: 0, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        }
    }
    
    func flip() {
        UIView.transition(from: backImageView, to: frontImageView, duration: 0.3, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
    }
    
    func flipBack() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            
            UIView.transition(from: self.frontImageView, to: self.backImageView, duration: 0.3, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        }
        
    }
    
    func removeMatchedPairs() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.backImageView.alpha = 0
                self.frontImageView.alpha = 0
            }, completion: nil)
        }
    }
}
