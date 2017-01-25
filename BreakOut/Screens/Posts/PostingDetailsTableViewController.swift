//
//  PostingDetailsTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 14.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

import Flurry_iOS_SDK
import Crashlytics

class PostingDetailsTableViewController: UITableViewController {
    
    var postingID: Int = Int()
    
//    var posting: Posting? {
//        didSet {
//            tableView.reloadData()
//            //posting?.reload(tableView.reloadData)
//        }
//    }

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
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
//            return posting?.comments!.count ?? 0
            return 0
        case 2:
            if CurrentUser.shared.isLoggedIn() {
                return 1
            }else{
                return 0
            }
        default:
            return 0
        }
    }
    
    func configureCommentCell(_ cell: PostingCommentTableViewCell, indexPath: IndexPath) {
//        let comments = posting?.comments![(indexPath as NSIndexPath).row]
//        cell.teamNameLabel.text = comments!.name ?? ""
//        cell.timestampLabel.text = comments!.date.toString() ?? ""
//        cell.commentMessageLabel.text = comments!.text ?? ""
//        //cell.teamPictureImageView.image = comments!.profilePic?.getImage() ?? UIImage(named: "emptyProfilePic")
//        if comments?.profilePicURL != nil {
//            cell.teamPictureImageView.setImageWith(URL(string: comments!.profilePicURL!)!)
//        }else{
            cell.teamPictureImageView.image = UIImage(named: "emptyProfilePic")
//        }
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }
    
    func configurePostingCell(_ cell: PostingTableViewCell) {
//        // Configure cell with the BOPost model
//        cell.messageLabel?.text = self.posting!.text
//        cell.timestampLabel?.text = self.posting!.date.toString()
//        
//        if (posting!.locality != nil && posting!.locality != "") {
//            cell.locationLabel?.text = posting!.locality
//        }else if(posting!.latitude != nil && posting!.longitude != nil) {
//            if (posting!.latitude!.int32Value != 0 && posting!.longitude!.int32Value != 0){
//                cell.locationLabel?.text = String(format: "lat: %3.3f long: %3.3f",posting!.latitude!, posting!.longitude!)
//            }
//        }else{
//            cell.locationLabel?.text = NSLocalizedString("unknownLocation", comment: "unknown location")
//        }
//        
//        // Check if Posting has an attached media file
//        //print(self.posting?.images)
//        /*if let image:BOImage = self.posting?.images.first {
//            let uiimage: UIImage = image.getImage()
//            if uiimage.hasContent() == true {
//                cell.postingPictureImageView.image = image.getImage()
//                cell.postingPictureImageViewHeightConstraint.constant = 120.0
//            }else{
//                cell.postingPictureImageViewHeightConstraint.constant = 0.0
//            }
//        }else{
//            cell.postingPictureImageView.image = UIImage()
//            cell.postingPictureImageViewHeightConstraint.constant = 0.0
//        }*/
//        if posting!.imageURL != nil {
//            cell.postingPictureImageView.setImageWith(URL(string: posting!.imageURL!)!)
//            cell.postingPictureImageViewHeightConstraint.constant = 120.0
//        }else{
//            cell.postingPictureImageView.image = UIImage()
//            cell.postingPictureImageViewHeightConstraint.constant = 0.0
//        }
//        
//        // Set the team image & name
//        if posting!.teamName != nil {
//            cell.teamNameLabel.text = posting!.teamName
//        }
//        /*if posting!.team != nil {
//            cell.teamNameLabel.text = posting!.team?.name
//        }*/
//        cell.teamPictureImageView?.image = posting?.team?.profilePic?.image ?? UIImage(named: "emptyProfilePic")
//        
//        
//        // Check if Posting has an attached challenge
//        if posting!.challenge != nil {
//            // Challenge is attached -> Show the challenge box
//            cell.challengeLabel.text = posting!.challenge?.text
//            cell.challengeLabelHeightConstraint?.constant = 34.0
//            cell.challengeView?.isHidden = false
//        }else{
//            cell.challengeLabel.text = ""
//            cell.challengeLabelHeightConstraint.constant = 0.0
//            cell.challengeViewHeightConstraint.constant = 0.0
//            cell.challengeView.isHidden = true
//        }
//        
//        if posting!.flagNeedsUpload == true {
//            cell.statusLabel?.text = "Wartet auf Upload zum Server."
//        }else{
//            cell.statusLabel?.text = ""
//        }
//        
//        // Add count for comments
//        cell.commentsButton?.setTitle(String(format: "%i %@", posting!.comments!.count, NSLocalizedString("comments", comment: "Comments")), for: UIControlState())
        
        cell.parentTableViewController = self
        
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostingTableViewCell", for: indexPath) as! PostingTableViewCell
            configurePostingCell(cell)
            return cell
        }else if (indexPath as NSIndexPath).section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostingCommentTableViewCell", for: indexPath) as! PostingCommentTableViewCell
            configureCommentCell(cell, indexPath: indexPath)
            return cell
        }else if (indexPath as NSIndexPath).section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostingCommentInputTableViewCell", for: indexPath)
            if let c = cell as? PostingCommentInputTableViewCell {
//                c.post = posting
//                c.reloadHandler = tableView.reloadData
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
