//
//  RankingViewController.swift
//  Memory Game
//
//  Created by Louis Hon on 22/11/2019.
//  Copyright © 2019 Louis Hon. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var currentRankings = [Ranking]()
    var sortedRankings = [Ranking]()
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        view.backgroundColor = #colorLiteral(red: 0.9999378324, green: 0.897490561, blue: 0.8938757777, alpha: 1)
        self.tableView.backgroundView?.backgroundColor = #colorLiteral(red: 1, green: 0.8991835526, blue: 0.8941713354, alpha: 1)
        
        self.title = "Ranking"
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
}


extension RankingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return currentRankings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingCell", for: indexPath) as! RankingTableViewCell
        loadRanking()
        let ranking = currentRankings[indexPath.row]
        cell.rankingLabel?.text = String(indexPath.row + 1)
        cell.nameLabel?.text = ranking.name
        cell.scoreLabel?.text = String(ranking.score)
        
        return cell
    }

}


