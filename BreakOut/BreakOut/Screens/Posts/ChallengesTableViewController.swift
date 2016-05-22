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
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "BOChallenge")
        fetchRequest.fetchLimit = 100
        fetchRequest.fetchBatchSize = 20
        
        // Filter Food where type is breastmilk
        /*var predicate = NSPredicate(format: "%K == %@", "type", "breastmilk")
         fetchRequest.predicate = predicate*/
        
        // Sort by createdAt
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "amount", ascending: false)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSManagedObjectContext.MR_defaultContext(), sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Style the navigation bar
        self.navigationController!.navigationBar.translucent = false
        self.navigationController!.navigationBar.barTintColor = Style.mainOrange
        self.navigationController!.navigationBar.backgroundColor = Style.mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currSection = fetchedResultsController.sections?[section] {
            return currSection.numberOfObjects
        }
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChallengeTableViewCell", forIndexPath: indexPath) as! ChallengeTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: ChallengeTableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Configure cell with the BOPost model
        let challenge:BOChallenge = fetchedResultsController.objectAtIndexPath(indexPath) as! BOChallenge
        
        cell.challengeTitleLabel.text = String(format: "%.2f €", challenge.amount!.doubleValue)
        cell.challengeDescriptionLabel.text = challenge.text! + challenge.text! + challenge.text!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let challenge:BOChallenge = fetchedResultsController.objectAtIndexPath(indexPath) as! BOChallenge
        
        self.parentNewPostingTVC?.newChallenge = challenge
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let challenge:BOChallenge = fetchedResultsController.objectAtIndexPath(indexPath) as! BOChallenge
        
        if challenge.status?.lowercaseString == "proposed" || challenge.status?.lowercaseString == "accepted" {
            return true
        }
        
        return false
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let challenge:BOChallenge = fetchedResultsController.objectAtIndexPath(indexPath) as! BOChallenge
        
        if challenge.status?.lowercaseString == "proposed" || challenge.status?.lowercaseString == "accepted" {
            cell.alpha = 1.0
        }else{
            cell.alpha = 0.5
        }
    }

}
