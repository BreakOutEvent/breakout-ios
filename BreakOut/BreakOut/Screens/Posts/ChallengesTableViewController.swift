//
//  ChallengesTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 22.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

class ChallengesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var parentNewPostingTVC: NewPostingTableViewController?
    
    lazy var fetchedResultsController: NSFetchedResultsController<BOChallenge> = { [unowned self] in
        
        let fetchRequest = NSFetchRequest<BOChallenge>(entityName: "BOChallenge")
        fetchRequest.fetchLimit = 100
        fetchRequest.fetchBatchSize = 20
        
        // Filter Food where type is breastmilk
        /*var predicate = NSPredicate(format: "%K == %@", "type", "breastmilk")
         fetchRequest.predicate = predicate*/
        
        // Sort by createdAt
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "amount", ascending: false)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSManagedObjectContext.mr_default(), sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Style the navigation bar
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = Style.mainOrange
        self.navigationController!.navigationBar.backgroundColor = Style.mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.title = NSLocalizedString("challengeTitle", comment: "")
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error")
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
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currSection = fetchedResultsController.sections?[section] {
            return currSection.numberOfObjects
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeTableViewCell", for: indexPath) as! ChallengeTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: ChallengeTableViewCell, atIndexPath indexPath: IndexPath) {
        // Configure cell with the BOPost model
        guard let challenge = fetchedResultsController.object(at: indexPath) as? BOChallenge else {
            return
        }
        
        cell.challengeTitleLabel.text = String(format: "%.2f €", challenge.amount!.doubleValue)
        if let text = challenge.text {
             cell.challengeDescriptionLabel.text = text + text + text
        }
       
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let challenge: BOChallenge? = fetchedResultsController.object(at: indexPath) as BOChallenge
        
        self.parentNewPostingTVC?.newChallenge = challenge
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let challenge:BOChallenge = fetchedResultsController.object(at: indexPath) as! BOChallenge
        
        if challenge.status?.lowercased() == "proposed" || challenge.status?.lowercased() == "accepted" {
            return true
        }
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let challenge:BOChallenge = fetchedResultsController.object(at: indexPath) as! BOChallenge
        
        if challenge.status?.lowercased() == "proposed" || challenge.status?.lowercased() == "accepted" {
            cell.alpha = 1.0
        }else{
            cell.alpha = 0.5
        }
    }

}
