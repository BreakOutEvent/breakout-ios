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
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: #selector(filterButtonPressed))
        navigationItem.rightBarButtonItem = rightButton
        
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
        return cell
    }
    
    func configureCell(cell: PostingTableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Configure cell with the BOPost model
        let posting = fetchedResultsController.objectAtIndexPath(indexPath) as! BOPost
        cell.messageLabel?.text = posting.text
        cell.timestampLabel?.text = posting.date.toNaturalString(NSDate())
        if posting.city != nil  {
            cell.locationLabel?.text = posting.city
        }else{
            cell.locationLabel?.text = posting.longitude.stringValue + posting.latitude.stringValue
        }
        
        let imagesMutableSet:NSMutableSet = posting.images
        var imagesArray = imagesMutableSet.allObjects
        
        if imagesArray.count>0 {
            let image: BOImage = imagesArray[0] as! BOImage
            cell.teamPictureImageView.image = image.getImage()
        }
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
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
