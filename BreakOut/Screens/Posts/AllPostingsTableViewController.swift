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
import Sweeft
    
import Flurry_iOS_SDK
import Crashlytics

class AllPostingsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var allPostingsArray = [Post]()
    var lastLoadedPage: Int = 0
    var isLoading: Bool = false
    
    func loadNewPageOfPostings() {
        self.lastLoadedPage += 1
        self.loadPostingsFromBackend(self.lastLoadedPage)
    }
    
    func loadPostingsFromBackend(_ page: Int = 0) {
        self.loadingCell(true)
        BONetworkIndicator.si.increaseLoading()
        Post.get(page: page).onSuccess { newPosts in
            newPosts >>> **self.tableView.reloadData
            self.allPostingsArray.append(contentsOf: newPosts)
            self.tableView.reloadData()
            self.tableView.reloadInputViews()
            self.lastLoadedPage = page
            self.loadingCell(false)
            BONetworkIndicator.si.decreaseLoading()
        }
        .onError(call: **{
            BONetworkIndicator.si.decreaseLoading()
            self.loadingCell(false)
        })
    }
    
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
        
        // Create menu buttons for navigation item
        let barButtonImage = UIImage(named: "menu_Icon_white")
        if barButtonImage != nil {
            self.addLeftBarButtonWithImage(barButtonImage!)
        }
        
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
        let posting = self.allPostingsArray[indexPath.row]
        cell.messageLabel?.text = posting.text

        let date = posting.date
        cell.timestampLabel?.text = date.toString()

        if (posting.location.locality != nil && posting.location.locality != "") {
            cell.locationLabel?.text = posting.location.locality
        } else if (Int(posting.location.latitude) != 0 && Int(posting.location.longitude) != 0) {
                cell.locationLabel?.text = String(format: "lat: %3.3f long: %3.3f", posting.location.latitude, posting.location.longitude)
        } else {
            cell.locationLabel?.text = NSLocalizedString("unknownLocation", comment: "unknown location")
        }

        // Check if Posting has an attached media file
        if let image = posting.media.flatMap({ $0.image }).first {
            cell.postingPictureImageView.image = image
            cell.postingPictureImageViewHeightConstraint.constant = 120.0
        } else {
            cell.postingPictureImageView.image = UIImage()
            cell.postingPictureImageViewHeightConstraint.constant = 0.0
        }

        // Set the team image & name
        if posting.participant.team?.name != nil {
            cell.teamNameLabel.text = posting.participant.team?.name
        }
        cell.teamPictureImageView.image = posting.participant.image?.image ?? UIImage(named: "emptyProfilePic")


        // Check if Posting has an attached challenge
        if posting.challenge != nil {
            cell.challengeLabel.text = posting.challenge?.text
            cell.challengeLabelHeightConstraint.constant = 34.0
            cell.challengeView.isHidden = false
        } else {
            cell.challengeLabel.text = ""
            cell.challengeLabelHeightConstraint.constant = 0.0
            cell.challengeViewHeightConstraint.constant = 0.0
            cell.challengeView.isHidden = true
        }
        
        // Add count for comments
        cell.commentsButton.setTitle(String(format: "%i %@", posting.comments.count, NSLocalizedString("comments", comment: "Comments")), for: UIControlState())
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let postingDetailsTableViewController: PostingDetailsTableViewController = storyboard.instantiateViewController(withIdentifier: "PostingDetailsTableViewController") as! PostingDetailsTableViewController
        
        postingDetailsTableViewController.posting = self.allPostingsArray[indexPath.row]
        
        self.navigationController?.pushViewController(postingDetailsTableViewController, animated: true)
    }
}
