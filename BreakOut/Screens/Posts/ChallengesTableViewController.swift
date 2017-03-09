//
//  ChallengesTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 22.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Sweeft

class ChallengesTableViewController: UITableViewController {
    
    var parentNewPostingTVC: NewPostingTableViewController?
    var challenges = [Challenge]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Style the navigation bar
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = .mainOrange
        self.navigationController!.navigationBar.backgroundColor = .mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.title = "challengeTitle".local
        
        let event = CurrentUser.shared.currentTeamId()
        let team = CurrentUser.shared.currentTeamId()
        Challenge.get(event: event, team: team).onSuccess { challenges in
            self.challenges = challenges
            self.tableView.reloadData()
        }
        .onError { error in
            print(error)
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 175.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challenges.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeTableViewCell", for: indexPath) as! ChallengeTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: ChallengeTableViewCell, atIndexPath indexPath: IndexPath) {
        // Configure cell with the BOPost model
        
        let challenge = challenges[indexPath.row]
        let title = String(format: "%.2f €", Double(challenge.amount.?))
        cell.challengeTitleLabel.text = title
        if let text = challenge.text {
             cell.challengeDescriptionLabel.text = text
        }
       
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.parentNewPostingTVC?.newChallenge = challenges[indexPath.row]
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let challenge = challenges[indexPath.row]
        if challenge.status?.lowercased() == "proposed" || challenge.status?.lowercased() == "accepted" {
            return true
        }
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let challenge = challenges[indexPath.row]
        
        if challenge.status?.lowercased() == "proposed" || challenge.status?.lowercased() == "accepted" {
            cell.alpha = 1.0
        }else{
            cell.alpha = 0.5
        }
    }

}
