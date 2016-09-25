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
    var date: Date
    var profilePicURL: String?
    
    required init(dict: NSDictionary) {
        uuid = dict.value(forKey: "id") as! NSInteger
        text = dict.value(forKey: "text") as? String
        let unixTimestamp = dict.value(forKey: "date") as! NSNumber
        date = Date(timeIntervalSince1970: unixTimestamp.doubleValue)
        if let user = dict.value(forKey: "user") as? NSDictionary, let first = user.value(forKey: "firstname") as? String,
            let last = user.value(forKey: "lastname") as? String {
            name = first + " " + last
            if let profilePicDict = user.value(forKey: "profilePic") as? NSDictionary {
                if let id = profilePicDict.value(forKey: "id") as? Int, let sizes = profilePicDict.value(forKey: "sizes") as? [NSDictionary] {
                    let image: NSDictionary?
                    if BOSynchronizeController.sharedInstance.internetReachability == "wifi" {
                        let deviceHeight = UIScreen.main.bounds.height
                        image = sizes.filter() { item in
                            if let height = item.value(forKey: "height") as? Int {
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
                    if let url = image?.value(forKey: "url") as? String {
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
    var date: Date
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
        self.uuid = dict.value(forKey: "id") as! NSInteger
        self.text = dict.value(forKey: "text") as? String
        self.comments = Array()
        let unixTimestamp = dict.value(forKey: "date") as! NSNumber
        self.date = Date(timeIntervalSince1970: unixTimestamp.doubleValue)
        
        if let longitude: NSNumber = (dict.value(forKey: "postingLocation")! as AnyObject).value(forKey: "longitude") as? NSNumber {
            self.longitude = longitude
        }
        if let latitude: NSNumber = (dict.value(forKey: "postingLocation")! as AnyObject).value(forKey: "latitude") as? NSNumber {
            self.latitude = latitude
        }
        
        if let mediaArray = dict.value(forKey: "media") as? [NSDictionary] {
            for item in mediaArray {
                // Handle Images
                if let id = item.value(forKey: "id") as? Int, let sizes = item.value(forKey: "sizes") as? [NSDictionary] {
                    let image: NSDictionary?
                    if BOSynchronizeController.sharedInstance.internetReachability == "wifi" {
                        let deviceHeight = UIScreen.main.bounds.height
                        image = sizes.filter() { item in
                            if let height = item.value(forKey: "height") as? Int {
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
                    if let url = image?.value(forKey: "url") as? String {
                        self.imageURL = url
                    }
                }
                
            }
        }
        if let commentsArray = dict.value(forKey: "comments") as? [NSDictionary] {
            for item in commentsArray {
                let newComment: Comment = Comment(dict: item)
                self.comments?.append(newComment)
                // Handle Comments
            }
        }
        
        if let userDictionary = dict.value(forKey: "user") as? NSDictionary {
            if let participantDictionary = userDictionary.value(forKey: "participant") as? NSDictionary {
                let teamid = participantDictionary.value(forKey: "teamId")
            }
        }
        
        if let postingLocationDictionary = dict.value(forKey: "postingLocation") as? NSDictionary {
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
    
    func loadPostingsFromBackend(_ page: Int = 0) {
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
    
    lazy var fetchedResultsController: NSFetchedResultsController<BOPost> = {
        let fetchRequest = NSFetchRequest<BOPost>(entityName: "BOPost")
        fetchRequest.fetchLimit = 100
        fetchRequest.fetchBatchSize = 20
        
        // Filter Food where type is breastmilk
        var predicate = NSPredicate(format: "%K != %@", "flagNeedsDownload", true as CVarArg)
        fetchRequest.predicate = predicate
        
        // Sort by createdAt
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSManagedObjectContext.mr_default(), sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    func loadingCell(_ isLoading: Bool = false) {
        self.isLoading = isLoading
        let indexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0)-1, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style the navigation bar
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = Style.mainOrange
        self.navigationController!.navigationBar.backgroundColor = Style.mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
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
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.allPostingsArray.removeAll()
        self.tableView.reloadData()
        
        self.loadPostingsFromBackend(0)
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isKind(of: LoadingTableViewCell.self) {
            if self.isLoading {
                cell.alpha = 0
            }else{
                cell.alpha = 1
            }
        }
        
        if (indexPath as NSIndexPath).row == self.tableView.numberOfRows(inSection: (indexPath as NSIndexPath).section)-1 {
            self.loadNewPageOfPostings()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Tracking
        Flurry.logEvent("/AllPostingsTVC", timed: true)
        Answers.logCustomEvent(withName: "/AllPostingsTVC", customAttributes: [:])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Flurry.endTimedEvent("/AllPostingsTVC", withParameters: nil)
    }
    
    func filterButtonPressed() {
        //TODO
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
        self.tableView.reloadInputViews()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        /*if let sections = fetchedResultsController.sections {
            return sections.count
        }*/
        return 1
        //return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*if let currSection = fetchedResultsController.sections?[section] {
            return currSection.numberOfObjects
        }*/
        return self.allPostingsArray.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ((indexPath as NSIndexPath).row == self.tableView.numberOfRows(inSection: (indexPath as NSIndexPath).section)-1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell", for: indexPath) as! LoadingTableViewCell
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostingTableViewCell", for: indexPath) as! PostingTableViewCell
        //configureCell(cell, atIndexPath: indexPath)
            configureCellFromDict(cell, atIndexPath: indexPath)
            cell.parentTableViewController = self
            return cell
        }
    }
    
    func configureCellFromDict(_ cell: PostingTableViewCell, atIndexPath indexPath: IndexPath) {
        let posting:Posting = self.allPostingsArray[(indexPath as NSIndexPath).row]
        cell.messageLabel?.text = posting.text
        
        let date = posting.date
        cell.timestampLabel?.text = date.toString()
        
        if (posting.locality != nil && posting.locality != "") {
            cell.locationLabel?.text = posting.locality
        }else if(posting.latitude != nil && posting.longitude != nil) {
            if (posting.latitude!.int32Value != 0 && posting.longitude!.int32Value != 0){
                cell.locationLabel?.text = String(format: "lat: %3.3f long: %3.3f",posting.latitude!, posting.longitude!)
            }
        }else{
            cell.locationLabel?.text = NSLocalizedString("unknownLocation", comment: "unknown location")
        }
        
        // Check if Posting has an attached media file
        if posting.imageURL != nil {
            cell.postingPictureImageView.setImageWith(URL(string: posting.imageURL!)!)
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
            cell.challengeView.isHidden = false
        }else{
            cell.challengeLabel.text = ""
            cell.challengeLabelHeightConstraint.constant = 0.0
            cell.challengeViewHeightConstraint.constant = 0.0
            cell.challengeView.isHidden = true
        }
        
        if posting.flagNeedsUpload == true {
            cell.statusLabel.text = "Wartet auf Upload zum Server."
        }else{
            cell.statusLabel.text = ""
        }
        
        // Add count for comments
        cell.commentsButton.setTitle(String(format: "%i %@", posting.comments!.count, NSLocalizedString("comments", comment: "Comments")), for: UIControlState())
        
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }
    
    func configureCell(_ cell: PostingTableViewCell, atIndexPath indexPath: IndexPath) {
        // Configure cell with the BOPost model
        let posting:BOPost = fetchedResultsController.object(at: indexPath) as! BOPost
        
        posting.printToLog()
        
        cell.messageLabel?.text = posting.text
        
        let date = posting.date
        cell.timestampLabel?.text = date.toString()
        
        if (posting.locality != nil && posting.locality != "") {
            cell.locationLabel?.text = posting.locality
        }else if (posting.latitude.int32Value != 0 && posting.longitude.int32Value != 0){
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
            cell.challengeView.isHidden = false
        }else{
            cell.challengeLabel.text = ""
            cell.challengeLabelHeightConstraint.constant = 0.0
            cell.challengeViewHeightConstraint.constant = 0.0
            cell.challengeView.isHidden = true
        }
        
        if posting.flagNeedsUpload == true {
            cell.statusLabel.text = "Wartet auf Upload zum Server."
        }else{
            cell.statusLabel.text = ""
        }
        
        // Add count for comments
        cell.commentsButton.setTitle(String(format: "%i %@", posting.comments.count, NSLocalizedString("comments", comment: "Comments")), for: UIControlState())
        
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let postingDetailsTableViewController: PostingDetailsTableViewController = storyboard.instantiateViewController(withIdentifier: "PostingDetailsTableViewController") as! PostingDetailsTableViewController
        
        //postingDetailsTableViewController.posting = (fetchedResultsController.objectAtIndexPath(indexPath) as! BOPost)
        postingDetailsTableViewController.posting = self.allPostingsArray[(indexPath as NSIndexPath).row] as Posting
        
        self.navigationController?.pushViewController(postingDetailsTableViewController, animated: true)
    }
}
