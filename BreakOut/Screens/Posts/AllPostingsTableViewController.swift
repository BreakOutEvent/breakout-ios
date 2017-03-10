    //
//  AllPostingsTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 24.04.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

import Sweeft
    
import Flurry_iOS_SDK
import Crashlytics

class AllPostingsTableViewController: UITableViewController, PersistentViewController {
    
    static var shared: UIViewController?
    
    var allPostingsArray = [Post]()
    var lastLoadedPage: Int = -1
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
            self.lastLoadedPage = page
            self.tableView.reloadData()
            self.tableView.reloadInputViews()
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "allPostingsTitle".local
        
        // Create menu buttons for navigation item
        let barButtonImage = UIImage(named: "menu_Icon_white")
        if barButtonImage != nil {
            self.addLeftBarButtonWithImage(barButtonImage!)
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 175.0
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Style the navigation bar
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = .mainOrange
        self.navigationController!.navigationBar.backgroundColor = .mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
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
            } else {
                cell.alpha = 1
            }
        }
        
        if !isLoading, (indexPath as NSIndexPath).row == self.tableView.numberOfRows(inSection: (indexPath as NSIndexPath).section)-1 {
            self.loadNewPageOfPostings()
        }
        
        if let cell = cell as? PostingTableViewCell {
            cell.loadInterface()
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PostingTableViewCell {
            cell.video?.pause() // Pause video when you're not it's not on screen
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
        if indexPath.row == self.tableView.numberOfRows(inSection: indexPath.section) - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell", for: indexPath) as! LoadingTableViewCell
            cell.activityIndicator.startAnimating()
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
        cell.posting = posting
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let postingDetailsTableViewController: PostingDetailsTableViewController = storyboard.instantiateViewController(withIdentifier: "PostingDetailsTableViewController") as! PostingDetailsTableViewController
        
        postingDetailsTableViewController.posting = self.allPostingsArray[indexPath.row]
        
        self.navigationController?.pushViewController(postingDetailsTableViewController, animated: true)
    }
}
