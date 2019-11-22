//
//  ViewController.swift
//  Memory Game
//
//  Created by Louis Hon on 22/11/2019.
//  Copyright © 2019 Louis Hon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var highscoreButton: UIButton!
    @IBOutlet var containerView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    var model = CardModel()
    var cardArray = [Card]()
    
    var currentScore = Int()
    var currentRankings = [Ranking]()
    var sortedRankings = [Ranking]()
    
    var highestScore = Int()
    
    var firstFlippedCardIndex: IndexPath?
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1, green: 0.8991835526, blue: 0.8941713354, alpha: 1)
        
        setupGame()
        cardArray = model.getCards()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    // MARK: - Game Logic
    
    func checkIfCardMatches(_ secondFlippedCardIndex: IndexPath) {
        
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCollectionViewCell
        
        let cardOne = cardArray[firstFlippedCardIndex!.row]
        let cardTwo = cardArray[secondFlippedCardIndex.row]
        
        // Compare the two cards
        if cardOne.imageName == cardTwo.imageName {
            
            cardOne.isMatched = true
            cardTwo.isMatched = true
            
            // Add current score when matched
            currentScore += 5
            scoreLabel.text = "Score: \(currentScore)"
            
            // Update highest score on screen
            updateHighestScore()
            
            // Remove matched cards from game board
            cardOneCell?.removeMatchedPairs()
            cardTwoCell?.removeMatchedPairs()
            
            // Check whether there are any cards left
            checkGameEnded()
            
        } else {
            
            cardOne.isFlipped = false
            cardTwo.isFlipped = false
            
            // Deduct current score when not matched
            currentScore -= 1
            scoreLabel.text = "Score: \(currentScore)"
            
            // Update highest score on screen
            updateHighestScore()
            
            cardOneCell?.flipBack()
            cardTwoCell?.flipBack()
        }
        
        // Reload firstFlippedCard when nil
        if cardOneCell == nil {
            collectionView.reloadItems(at: [firstFlippedCardIndex!])
        }
        
        firstFlippedCardIndex = nil
    }
    
    func checkGameEnded() {
        var isGameWon = true
        
        // Determine if there any cards unmatched
        for card in cardArray {
            if card.isMatched == false {
                isGameWon = false
                break
            }
        }
        
        // If yes, user has won and prompt alert for input
        if isGameWon {
            // Show popup and allow user input
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
                self.showSubmitAlert()
            }
        }
    }
    
    func submit(_ input: String, _ score: Int) {
        
        if isValidName(input) {
            // Determine whether current score is a top score
            updateCurrentRanking(input)
            
            if isHighsocreBeaten(score) {
                guard let index = currentRankings.firstIndex(where: { $0.score == currentScore }) else { return }
                showMessage(title: "Congratulations", message: "You ranked number \(index + 1)!")
            } else {
                showMessage(title: "Game Over", message: "You can do better!")
            }
            
            // Save current ranking
            saveCurrentRanking()
            
        } else {
            // Dismiss error message and show input name alert again
            showInvalidNameAlert()
        }
    }
    
    func updateHighestScore() {
        if currentRankings.isEmpty {
            // Current score is negative when highest score is 0
            if currentScore < 0 || currentScore > highestScore {
                highestScore = currentScore
                highscoreButton.setTitle("Highest: \(highestScore)", for: .normal)
            }
        } else {
            if currentScore > currentRankings[0].score {
                highestScore = currentScore
                highscoreButton.setTitle("Highest: \(highestScore)", for: .normal)
            }
        }
    }
    
    func isHighsocreBeaten(_ score: Int) -> Bool {
        
        for i in 0...currentRankings.count - 1 {
            if currentScore >= currentRankings[i].score {
                return true
            }
        }
        return false
    }
    
    func updateCurrentRanking(_ input: String) {
        
        if currentRankings.isEmpty {
            // If currentRanking is empty, add the first one
            currentRankings = [Ranking(rank: 1, name: input, score: currentScore)]
            
        } else {
            // If not empty, compare the scores and determine whether currentScore is a top score
            for i in 0...currentRankings.count - 1 {
                currentRankings.append(Ranking(rank: i, name: input, score: currentScore))
                currentRankings = sortCurrentRanking(&currentRankings)
                
                if currentRankings.count > 10 {
                    
                    currentRankings = sortCurrentRanking(&currentRankings)
                    currentRankings.removeLast()
                }
                return
            }
        }
    }
    
    func sortCurrentRanking(_ ranking: inout [Ranking]) -> [Ranking] {
        
        for rankOne in 0..<ranking.count {
            var highestRank = rankOne
            
            for rankTwo in rankOne + 1..<ranking.count {
                if ranking[rankTwo].score > ranking[highestRank].score {
                    highestRank = rankTwo
                }
            }
            
            if rankOne != highestRank {
                ranking.swapAt(rankOne, highestRank)
            }
            
        }
        
        // Update rank value
        for num in 0..<ranking.count{
            ranking[num].rank = num + 1
        }
        
        return ranking
    }
    
    func saveCurrentRanking() {
        let encodedData = try? JSONEncoder().encode(currentRankings)
        //        let encodedData = try? JSONEncoder().encode(sortedRankings)
        userDefaults.set(encodedData, forKey: "SavedRankings")
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        let main = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let destVC = main.instantiateViewController(identifier: "Ranking") as? RankingViewController {
            loadRanking()
            if currentRankings.isEmpty {
                showErrorMessage(title: "Not Available", message: "Please complete your first game.")
                print("LOG/ Cannot perform segue")
                return
            }
            destVC.currentRankings = currentRankings
            navigationController?.pushViewController(destVC, animated: true)
        }
    }
    
    func loadRanking() {
        if let savedData = userDefaults.data(forKey: "SavedRankings") {
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode([Ranking].self, from: savedData)
                currentRankings = decodedData
            } catch {
                print("Cannot load data.")
            }
        }
    }
    
    func isValidName(_ input: String) -> Bool {
        // Name Length to be 1 char mininum and 8 chars maximum
        let nameRegex = "^[A-Za-z]{1,8}$"
        let trimmedString = input.trimmingCharacters(in: .whitespaces)
        let validateName = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        let isValidName = validateName.evaluate(with: trimmedString)
        return isValidName
    }
    
    func resetGame() {
        cardArray.removeAll()
        cardArray = model.getCards()
        currentScore = 0
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        setupGame()
    }
    
    // MARK: - Setup Game Screen
    
    func setupGame() {
        // load current ranking
        loadRanking()
        
        // Show current score
        scoreLabel.text = "Score: \(currentScore)"
        
        // Check whether there is an existing current ranking
        if currentRankings.isEmpty {
            // Set highscore to 0
            highscoreButton.setTitle("Highest: -", for: .normal)
            
        } else {
            // Set to highest score
            highscoreButton.setTitle("Highest: \(currentRankings[0].score)", for: .normal)
        }
    }
    
    // MARK: - Alert messages
    
    func showSubmitAlert() {
        let ac = UIAlertController(title: "Good Job!", message: "You have found all the matching pairs.", preferredStyle: .alert)
        
        ac.addTextField(configurationHandler: { (textField: UITextField) -> Void in
            textField.placeholder = "Enter your name"
        })
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] action in
            guard let name = ac?.textFields?[0].text else { return }
            self?.submit(name, self!.currentScore)
        }
        
        ac.addAction(submitAction)
        self.present(ac, animated: true)
    }
    
    func showInvalidNameAlert() {
        let ac = UIAlertController(title: "Invalid Input", message: "Name must contain alphabets only and 1 to 8 characters long.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Try again", style: .default) { (_) in
            ac.dismiss(animated: true, completion: {
                self.showSubmitAlert()
            })
        }
        ac.addAction(okAction)
        present(ac, animated: true)
    }
    
    func showMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let viewAction = UIAlertAction(title: "View Rankings", style: .default) { _ in
            self.buttonTapped(UIButton())
            self.resetGame()
        }
        
        let retartAction = UIAlertAction(title: "Restart", style: .default) { _ in
            self.resetGame()
        }
        
        ac.addAction(viewAction)
        ac.addAction(retartAction)
        present(ac, animated: true)
    }
    
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}


// MARK: - UICollectionView Protocl Methods & FlowLayout

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return cardArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        let card = cardArray[indexPath.row]
        cell.setCard(card)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        let card = cardArray[indexPath.row]
        
        if !card.isFlipped && !card.isMatched {
            // Flip the card
            cell.flip()
            card.isFlipped = true
            // Determine whether it's the first card or second card
            if firstFlippedCardIndex == nil {
                firstFlippedCardIndex = indexPath
            } else {
                // Perform the matching logic
                checkIfCardMatches(indexPath)
            }
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 4
        let interimItemSpacing: CGFloat = 5
        let availableWidth = containerView.frame.width
        let availableHeight = containerView.frame.height
        
        let width = (availableWidth - (itemsPerRow - 1) * interimItemSpacing) / itemsPerRow
        let height = (availableHeight - (itemsPerRow - 1) * interimItemSpacing) / itemsPerRow
        
        if availableWidth > availableHeight {
            return CGSize(width: height, height: height)
        } else {
            return CGSize(width: width, height: width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}



