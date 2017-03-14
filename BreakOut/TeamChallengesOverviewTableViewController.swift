//
//  TeamChallengesOverviewTableViewController.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/14/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import UIKit

class TeamChallengesOverviewTableViewController: UITableViewController {
    
    var teamProfileController: TeamViewController?
    
    var remaining = [Challenge]()
    var completed = [Challenge]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 175.0
        
        teamProfileController?.onChange { _ in
            self.load()
        }
        load()
    }
    
    var challenges: [[Challenge]] {
        return [remaining, completed]
    }
    
    func load() {
        teamProfileController?.team?.challenges().onSuccess { challenges in
            self.remaining = challenges |> { !$0.completed }
            self.completed = challenges |> { $0.completed }
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challenges[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeTableViewCell", for: indexPath)
        let challenge = challenges[indexPath.section][indexPath.row]
        if let cell = cell as? ChallengeTableViewCell {
            let title = String(format: "%.2f €", challenge.amount.?)
            cell.challengeTitleLabel.text = title
            cell.challengeDescriptionLabel.text = challenge.text
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "pending_challenges".local
        case 1:
            return "completed_challenges".local
        default:
            return nil
        }
    }
    

}
