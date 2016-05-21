//
//  PostingDetailsTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 14.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

class PostingDetailsTableViewController: UITableViewController {
    
    var postingID: Int = Int()
    
    var posting: BOPost?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("postingDetailsTitle", comment: "")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 175.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
            return posting?.comments.count ?? 0
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func configureCommentCell(cell: PostingCommentTableViewCell, indexPath: NSIndexPath) {
        let comments = posting?.comments.map({ $0 as BOComment })
        cell.commentMessageLabel.text = comments?[indexPath.row].text ?? ""
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }
    
    func configurePostingCell(cell: PostingTableViewCell) {
        // Configure cell with the BOPost model
        cell.messageLabel?.text = self.posting!.text
        cell.timestampLabel?.text = self.posting!.date.toNaturalString(NSDate())
        
        if (posting!.city != nil && posting!.city != "") {
            cell.locationLabel?.text = posting!.city
        }else if (posting!.latitude.intValue != 0 && posting!.longitude.intValue != 0){
            cell.locationLabel?.text = posting!.longitude.stringValue + "  " + posting!.latitude.stringValue
        }else{
            cell.locationLabel?.text = NSLocalizedString("unknownLocation", comment: "unknown location")
        }
        
        // Check if Posting has an attached media file
        if let image:BOImage = self.posting!.images.first {
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
        
        // Set the team image
        cell.teamPictureImageView.image = UIImage(named: "team_Icon")
        
        
        // Check if Posting has an attached challenge
        if true == true {
            // Challenge is attached -> Show the challenge box
            cell.challengeLabel.text = "was geht denn nun hier ab? Man kann sich echt nie sicher sein welche Idioten sich hier an den Beispieltexten vergreifen. Aber lustig ist es schon ;)"
        }else{
            cell.challengeViewHeightConstraint.constant = 0.0
        }
        
        cell.parentTableViewController = self
        
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0  {
            let cell = tableView.dequeueReusableCellWithIdentifier("PostingTableViewCell", forIndexPath: indexPath) as! PostingTableViewCell
            configurePostingCell(cell)
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("PostingCommentTableViewCell", forIndexPath: indexPath) as! PostingCommentTableViewCell
            configureCommentCell(cell, indexPath: indexPath)
            return cell
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("PostingCommentInputTableViewCell", forIndexPath: indexPath)
            if let c = cell as? PostingCommentInputTableViewCell {
                c.post = posting
                c.reloadHandler = tableView.reloadData
            }
            return cell
        }else{
            let cell = UITableViewCell()
            return cell
        }
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
