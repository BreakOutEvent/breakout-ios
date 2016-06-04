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

import Flurry_iOS_SDK
import Crashlytics

class Comment: NSObject {
    var uuid: NSInteger
    var postID: NSInteger?
    var text: String?
    var name: String?
    var date: NSDate
    var profilePicURL: String?
    
    required init(dict: NSDictionary) {
        uuid = dict.valueForKey("id") as! NSInteger
        text = dict.valueForKey("text") as? String
        let unixTimestamp = dict.valueForKey("date") as! NSNumber
        date = NSDate(timeIntervalSince1970: unixTimestamp.doubleValue)
        if let user = dict.valueForKey("user") as? NSDictionary, first = user.valueForKey("firstname") as? String,
            last = user.valueForKey("lastname") as? String {
            name = first + " " + last
            if let profilePicDict = user.valueForKey("profilePic") as? NSDictionary {
                if let id = profilePicDict.valueForKey("id") as? Int, sizes = profilePicDict.valueForKey("sizes") as? [NSDictionary] {
                    let image: NSDictionary?
                    if BOSynchronizeController.sharedInstance.internetReachability == "wifi" {
                        let deviceHeight = UIScreen.mainScreen().bounds.height
                        image = sizes.filter() { item in
                            if let height = item.valueForKey("height") as? Int {
                                return (CGFloat) (height) < deviceHeight
                            }
                            return false
                            }.last
                    } else {
                        image = sizes.first
                        /*if let last = sizes.last, lastURL = last.valueForKey("url") as? String {
                         betterURL = lastURL
                         }*/
                    }
                    if let url = image?.valueForKey("url") as? String {
                        self.profilePicURL = url
                    }
                }
            }
        }
    }
    
}

class Posting: NSObject {
    
    var uuid: NSInteger?
    var text: String?
    var teamName: String?
    var teamImageURL: String?
    var date: NSDate
    var longitude: NSNumber?
    var latitude: NSNumber?
    var flagNeedsUpload: Bool?
    var flagNeedsDownload: Bool?
    var team: BOTeam?
    var challenge: BOChallenge?
    var imageURL: String?
    var comments: Array<Comment>?
    var country: String?
    var locality: String?
    
    required init(dict: NSDictionary) {
        self.uuid = dict.valueForKey("id") as! NSInteger
        self.text = dict.valueForKey("text") as? String
        self.comments = Array()
        let unixTimestamp = dict.valueForKey("date") as! NSNumber
        self.date = NSDate(timeIntervalSince1970: unixTimestamp.doubleValue)
        
        if let longitude: NSNumber = dict.valueForKey("postingLocation")!.valueForKey("longitude") as? NSNumber {
            self.longitude = longitude
        }
        if let latitude: NSNumber = dict.valueForKey("postingLocation")!.valueForKey("latitude") as? NSNumber {
            self.latitude = latitude
        }
        
        if let mediaArray = dict.valueForKey("media") as? [NSDictionary] {
            for item in mediaArray {
                // Handle Images
                if let id = item.valueForKey("id") as? Int, sizes = item.valueForKey("sizes") as? [NSDictionary] {
                    let image: NSDictionary?
                    if BOSynchronizeController.sharedInstance.internetReachability == "wifi" {
                        let deviceHeight = UIScreen.mainScreen().bounds.height
                        image = sizes.filter() { item in
                            if let height = item.valueForKey("height") as? Int {
                                return (CGFloat) (height) < deviceHeight
                            }
                            return false
                            }.last
                    } else {
                        image = sizes.first
                        /*if let last = sizes.last, lastURL = last.valueForKey("url") as? String {
                            betterURL = lastURL
                        }*/
                    }
                    if let url = image?.valueForKey("url") as? String {
                        self.imageURL = url
                    }
                }
                
            }
        }
        if let commentsArray = dict.valueForKey("comments") as? [NSDictionary] {
            for item in commentsArray {
                let newComment: Comment = Comment(dict: item)
                self.comments?.append(newComment)
                // Handle Comments
            }
        }
        
        if let userDictionary = dict.valueForKey("user") as? NSDictionary {
            if let participantDictionary = userDictionary.valueForKey("participant") as? NSDictionary {
                let teamid = participantDictionary.valueForKey("teamId")
            }
        }
        
        if let postingLocationDictionary = dict.valueForKey("postingLocation") as? NSDictionary {
            if postingLocationDictionary.count > 0 {
                self.teamName = postingLocationDictionary["team"] as! String
                if let locationDataDict: NSDictionary = postingLocationDictionary["locationData"] as? NSDictionary {
                    if locationDataDict["COUNTRY"] != nil {
                        self.country = locationDataDict["COUNTRY"] as! String
                    }
                    if locationDataDict["LOCALITY"] != nil {
                        self.locality = locationDataDict["LOCALITY"] as! String
                    }
                }
            }
        }
    }
}

class AllPostingsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var allPostingsArray: Array<Posting> = Array()
    var lastLoadedPage: Int = 0
    var isLoading: Bool = false
    
    func loadNewPageOfPostings() {
        self.lastLoadedPage += 1
        self.loadPostingsFromBackend(self.lastLoadedPage)
    }
    
    func loadPostingsFromBackend(page: Int = 0) {
        //if BOSynchronizeController.sharedInstance.internetReachability == "wifi" {
        self.loadingCell(true)
        BONetworkIndicator.si.increaseLoading()
            BONetworkManager.doJSONRequestGET(BackendServices.PostingsOffsetLimit, arguments: [page,20], parameters: nil, auth: false) { (response) in
                if let postingsArray = response as? NSArray {
                    for postingDict:NSDictionary in postingsArray as! [NSDictionary] {
                        let newPosting: Posting = Posting(dict: postingDict)
                        self.allPostingsArray.append(newPosting)
                    }
                }
                
                self.tableView.reloadData()
                self.tableView.reloadInputViews()
                
                self.lastLoadedPage = page
                self.loadingCell(false)
                BONetworkIndicator.si.decreaseLoading()
            }
        //}
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "BOPost")
        fetchRequest.fetchLimit = 100
        fetchRequest.fetchBatchSize = 20
        
        // Filter Food where type is breastmilk
        var predicate = NSPredicate(format: "%K != %@", "flagNeedsDownload", true)
        fetchRequest.predicate = predicate
        
        // Sort by createdAt
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSManagedObjectContext.MR_defaultContext(), sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    func loadingCell(isLoading: Bool = false) {
        self.isLoading = isLoading
        let indexPath = NSIndexPath(forRow: self.tableView.numberOfRowsInSection(0)-1, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }

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
        
        /*do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error")
        }*/
        
        self.loadPostingsFromBackend(0)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 175.0
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.allPostingsArray.removeAll()
        self.tableView.reloadData()
        
        self.loadPostingsFromBackend(0)
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.isKindOfClass(LoadingTableViewCell) {
            if self.isLoading {
                cell.alpha = 0
            }else{
                cell.alpha = 1
            }
        }
        
        if indexPath.row == self.tableView.numberOfRowsInSection(indexPath.section)-1 {
            self.loadNewPageOfPostings()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tracking
        Flurry.logEvent("/AllPostingsTVC", timed: true)
        Answers.logCustomEventWithName("/AllPostingsTVC", customAttributes: [:])
    }
    
    override func viewDidDisappear(animated: Bool) {
        Flurry.endTimedEvent("/AllPostingsTVC", withParameters: nil)
    }
    
    func filterButtonPressed() {
        //TODO
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
        self.tableView.reloadInputViews()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        /*if let sections = fetchedResultsController.sections {
            return sections.count
        }*/
        return 1
        //return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*if let currSection = fetchedResultsController.sections?[section] {
            return currSection.numberOfObjects
        }*/
        return self.allPostingsArray.count + 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == self.tableView.numberOfRowsInSection(indexPath.section)-1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("LoadingTableViewCell", forIndexPath: indexPath) as! LoadingTableViewCell
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("PostingTableViewCell", forIndexPath: indexPath) as! PostingTableViewCell
        //configureCell(cell, atIndexPath: indexPath)
            configureCellFromDict(cell, atIndexPath: indexPath)
            cell.parentTableViewController = self
            return cell
        }
    }
    
    func configureCellFromDict(cell: PostingTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let posting:Posting = self.allPostingsArray[indexPath.row]
        cell.messageLabel?.text = posting.text
        
        let date = posting.date
        cell.timestampLabel?.text = date.toNaturalString(NSDate())
        
        if (posting.locality != nil && posting.locality != "") {
            cell.locationLabel?.text = posting.locality
        }else if(posting.latitude != nil && posting.longitude != nil) {
            if (posting.latitude!.intValue != 0 && posting.longitude!.intValue != 0){
                cell.locationLabel?.text = String(format: "lat: %3.3f long: %3.3f",posting.latitude!, posting.longitude!)
            }
        }else{
            cell.locationLabel?.text = NSLocalizedString("unknownLocation", comment: "unknown location")
        }
        
        // Check if Posting has an attached media file
        if posting.imageURL != nil {
            cell.postingPictureImageView.setImageWithURL(NSURL(string: posting.imageURL!)!)
            cell.postingPictureImageViewHeightConstraint.constant = 120.0
        }else{
            cell.postingPictureImageView.image = UIImage()
            cell.postingPictureImageViewHeightConstraint.constant = 0.0
        }
        /*if let image:BOImage = posting.images!.first {
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
        }*/
        
        // Set the team image & name
        if posting.teamName != nil {
            cell.teamNameLabel.text = posting.teamName
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
        cell.commentsButton.setTitle(String(format: "%i %@", posting.comments!.count, NSLocalizedString("comments", comment: "Comments")), forState: UIControlState.Normal)
        
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }
    
    func configureCell(cell: PostingTableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Configure cell with the BOPost model
        let posting:BOPost = fetchedResultsController.objectAtIndexPath(indexPath) as! BOPost
        
        posting.printToLog()
        
        cell.messageLabel?.text = posting.text
        
        let date = posting.date
        cell.timestampLabel?.text = date.toNaturalString(NSDate())
        
        if (posting.locality != nil && posting.locality != "") {
            cell.locationLabel?.text = posting.locality
        }else if (posting.latitude.intValue != 0 && posting.longitude.intValue != 0){
            cell.locationLabel?.text = String(format: "lat: %3.3f long: %3.3f",posting.latitude, posting.longitude)
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
        
        //postingDetailsTableViewController.posting = (fetchedResultsController.objectAtIndexPath(indexPath) as! BOPost)
        postingDetailsTableViewController.posting = self.allPostingsArray[indexPath.row] as Posting
        
        self.navigationController?.pushViewController(postingDetailsTableViewController, animated: true)
    }
}
