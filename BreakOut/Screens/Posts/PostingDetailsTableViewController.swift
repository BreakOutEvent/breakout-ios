 //
//  PostingDetailsTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 14.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Sweeft

import Flurry_iOS_SDK
import Crashlytics

class PostingDetailsTableViewController: UITableViewController {
    
    var postingID: Int = Int()
    
    var posting: Post! {
        didSet {
            posting >>> **self.tableView.reloadData
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("postingDetailsTitle", comment: "")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 175.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Tracking
        Flurry.logEvent("/PostingDetailsTVC", timed: true)
        Answers.logCustomEvent(withName: "/PostingDetailsTVC", customAttributes: [:])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Flurry.endTimedEvent("/PostingDetailsTVC", withParameters: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return posting.comments.count
        case 2:
            if CurrentUser.shared.isLoggedIn() {
                return 1
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func configureCommentCell(_ cell: PostingCommentTableViewCell, indexPath: IndexPath) {
        let comment = posting.comments[indexPath.row]
        cell.teamNameLabel.text = comment.participant.name
        cell.timestampLabel.text = comment.date.toString()
        cell.commentMessageLabel.text = comment.text ?? ""
        cell.teamPictureImageView.image = comment.participant.image?.image ?? UIImage(named: "emptyProfilePic")
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }
    
    func configurePostingCell(_ cell: PostingTableViewCell) {
        // Configure cell with the BOPost model
        cell.messageLabel?.text = self.posting!.text
        cell.timestampLabel?.text = self.posting!.date.toString()
        
        let latitude = (posting?.location?.latitude).?
        let longitude = (posting?.location?.longitude).?
        
        if posting?.location?.locality != nil && posting?.location?.locality != "" {
            cell.locationLabel?.text = posting!.location?.locality
        } else if posting.location?.latitude != nil && posting.location?.longitude != nil {
            if Int(latitude) != 0 && Int(longitude) != 0 {
                cell.locationLabel?.text = String(format: "lat: %3.3f long: %3.3f", latitude, longitude)
            }
        } else {
            cell.locationLabel?.text = NSLocalizedString("unknownLocation", comment: "unknown location")
        }
        
        if let image = posting.media.flatMap({ $0.image }).first {
            cell.postingPictureImageView.image = image
            cell.postingPictureImageViewHeightConstraint.constant = 120.0
        } else {
            cell.postingPictureImageView.image = UIImage()
            cell.postingPictureImageViewHeightConstraint.constant = 0.0
        }
        
        // Set the team image & name
        if posting.participant.team != nil {
            cell.teamNameLabel.text = posting.participant.team?.name
        }
        
        cell.teamPictureImageView?.image = posting.participant.image?.image ?? UIImage(named: "emptyProfilePic")
        
        
        // Check if Posting has an attached challenge
        if posting!.challenge != nil {
            // Challenge is attached -> Show the challenge box
            cell.challengeLabel.text = posting!.challenge?.text
            cell.challengeLabelHeightConstraint?.constant = 34.0
            cell.challengeView?.isHidden = false
        } else {
            cell.challengeLabel.text = ""
            cell.challengeLabelHeightConstraint.constant = 0.0
            cell.challengeViewHeightConstraint.constant = 0.0
            cell.challengeView.isHidden = true
        }
        
        // Add count for comments
        cell.commentsButton?.setTitle(String(format: "%i %@", posting.comments.count, NSLocalizedString("comments", comment: "Comments")), for: UIControlState())
        
        cell.parentTableViewController = self
        
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostingTableViewCell", for: indexPath) as! PostingTableViewCell
            configurePostingCell(cell)
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostingCommentTableViewCell", for: indexPath) as! PostingCommentTableViewCell
            configureCommentCell(cell, indexPath: indexPath)
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostingCommentInputTableViewCell", for: indexPath)
            if let c = cell as? PostingCommentInputTableViewCell {
                c.post = posting
                c.reloadHandler = tableView.reloadData
            }
            return cell
        } else {
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
