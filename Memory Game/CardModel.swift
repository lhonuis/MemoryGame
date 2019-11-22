//
//  CardModel.swift
//  Memory Game
//
//  Created by Louis Hon on 22/11/2019.
//  Copyright © 2019 Louis Hon. All rights reserved.
//

import Foundation

class CardModel {
    
    func getCards() -> [Card] {
        
        var cardArray = [Card]()
        var numArray = [Int]()
        
        // Randomly generate pairs of cards
        while numArray.count < 8 {
            
            let randNum = arc4random_uniform(8) + 1
            
            if numArray.contains(Int(randNum)) == false {
                
                // Make sure the number is going to be repeated
                numArray.append(Int(randNum))
                
                let cardOne = Card()
                cardOne.imageName = "color\(randNum)"
                cardArray.append(cardOne)
                
                let cardTwo = Card()
                cardTwo.imageName = "color\(randNum)"
                cardArray.append(cardTwo)
            }
        }
        
        return cardArray.shuffled()
    }
}
