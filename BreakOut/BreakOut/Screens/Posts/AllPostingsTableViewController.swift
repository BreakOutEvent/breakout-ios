//
//  AllPostingsTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 24.04.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

// Database
import MagicalRecord

import SwiftDate

class AllPostingsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "BOPost")
        fetchRequest.fetchLimit = 100
        fetchRequest.fetchBatchSize = 20
        
        // Filter Food where type is breastmilk
        /*var predicate = NSPredicate(format: "%K == %@", "type", "breastmilk")
        fetchRequest.predicate = predicate*/
        
        // Sort by createdAt
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
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
        
        self.title = NSLocalizedString("allPostingsTitle", comment: "")
        
        // Create save button for navigation item
        //let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: #selector(filterButtonPressed))
        //navigationItem.rightBarButtonItem = rightButton
        
        // Create menu buttons for navigation item
        let barButtonImage = UIImage(named: "menu_Icon_white")
        if barButtonImage != nil {
            self.addLeftBarButtonWithImage(barButtonImage!)
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error")
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 175.0
    }
    
    func filterButtonPressed() {
        //TODO
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
        let cell = tableView.dequeueReusableCellWithIdentifier("PostingTableViewCell", forIndexPath: indexPath) as! PostingTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        cell.parentTableViewController = self
        return cell
    }
    
    func configureCell(cell: PostingTableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Configure cell with the BOPost model
        let posting:BOPost = fetchedResultsController.objectAtIndexPath(indexPath) as! BOPost
        
        posting.printToLog()
        
        cell.messageLabel?.text = posting.text
        
        let date = posting.date
        cell.timestampLabel?.text = date.toNaturalString(NSDate())
        
        if (posting.city != nil && posting.city != "") {
            cell.locationLabel?.text = posting.city
        }else if (posting.latitude.intValue != 0 && posting.longitude.intValue != 0){
            cell.locationLabel?.text = posting.longitude.stringValue + "  " + posting.latitude.stringValue
        }else{
            cell.locationLabel?.text = NSLocalizedString("unknownLocation", comment: "unknown location")
        }

        // Check if Posting has an attached media file
        if let image:BOImage = posting.images.first {
            let uiimage: UIImage = image.getImage()
            if uiimage.hasContent() == true {
                cell.postingPictureImageView.image = image.getImage()
                cell.postingPictureImageViewHeightConstraint.constant = 120.0                
            }else{
                cell.postingPictureImageViewHeightConstraint.constant = 0.0
            }
        }else{
            cell.postingPictureImageView.image = UIImage()
            cell.postingPictureImageViewHeightConstraint.constant = 0.0
        }
        
        // Set the team image & name
        if posting.team != nil {
            cell.teamNameLabel.text = posting.team?.name
        }
        cell.teamPictureImageView.image = posting.team?.profilePic?.getImage() ?? UIImage(named: "emptyProfilePic")
        
        
        // Check if Posting has an attached challenge
        if posting.challenge != nil {
            // Challenge is attached -> Show the challenge box
            cell.challengeLabel.text = posting.challenge?.text
            cell.challengeLabelHeightConstraint.constant = 34.0
            cell.challengeView.hidden = false
        }else{
            cell.challengeLabel.text = ""
            cell.challengeLabelHeightConstraint.constant = 0.0
            cell.challengeViewHeightConstraint.constant = 0.0
            cell.challengeView.hidden = true
        }
        
        if posting.flagNeedsUpload == true {
            cell.statusLabel.text = "Wartet auf Upload zum Server."
        }else{
            cell.statusLabel.text = ""
        }
        
        // Add count for comments
        cell.commentsButton.setTitle(String(format: "%i %@", posting.comments.count, NSLocalizedString("comments", comment: "Comments")), forState: UIControlState.Normal)
        
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let postingDetailsTableViewController: PostingDetailsTableViewController = storyboard.instantiateViewControllerWithIdentifier("PostingDetailsTableViewController") as! PostingDetailsTableViewController
        
        postingDetailsTableViewController.posting = (fetchedResultsController.objectAtIndexPath(indexPath) as! BOPost)
        
        self.navigationController?.pushViewController(postingDetailsTableViewController, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
