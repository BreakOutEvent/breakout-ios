//
//  SidebarMenuTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 07.01.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

class SidebarMenuTableViewController: UITableViewController {
    
    @IBOutlet weak var userPictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userDistanceRemainingTimeLabel: UILabel!
    @IBOutlet weak var addUserpictureButton: UIButton!
    
// MARK: - Screen Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add the circle mask to the userpicture
        self.userPictureImageView.layer.cornerRadius = self.userPictureImageView.frame.size.width / 2.0
        self.userPictureImageView.clipsToBounds = true
        
        // Styling the Button for adding a userpicture if non exists.
        self.addUserpictureButton.backgroundColor = UIColor.whiteColor()
        self.addUserpictureButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.addUserpictureButton.layer.cornerRadius = self.addUserpictureButton.frame.size.width / 2.0
        
        self.fillInputsWithCurrentUserInfo()
        
        if self.userPictureImageView.image == nil {
            self.addUserpictureButton.hidden = false
        }else{
            self.addUserpictureButton.hidden = true
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showAllPostingsTVC), name: Constants.NOTIFICATION_NEW_POSTING_CLOSED_WANTS_LIST, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.fillInputsWithCurrentUserInfo()
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tracking
        //Flurry.logEvent("/user/profile", withParameters: nil, timed: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Tracking
        //Flurry.endTimedEvent("/user/profile", withParameters: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.NOTIFICATION_NEW_POSTING_CLOSED_WANTS_LIST, object: nil)
    }
    
    func fillInputsWithCurrentUserInfo() {
        self.usernameLabel.text = CurrentUser.sharedInstance.username()
        
        self.userPictureImageView.image = CurrentUser.sharedInstance.picture
        if self.userPictureImageView.image != nil {
            self.addUserpictureButton.hidden = true
        }
    }
    
    func showAllPostingsTVC() {
        if let slideMenuController = self.slideMenuController() {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("AllPostingsTableViewController")
        
            let navigationController = UINavigationController(rootViewController: controller!)
        
            slideMenuController.changeMainViewController(navigationController, close: true)
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 && indexPath.row == 1 && CurrentUser.sharedInstance.currentTeamId() < 0 {
            return false
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 && CurrentUser.sharedInstance.currentTeamId() < 0 {
            cell.alpha = 0.5
        }else{
            cell.alpha = 1.0
        }
    }
    
// MARK: - TableView Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if let slideMenuController = self.slideMenuController() {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier(cell.reuseIdentifier!)
            
            let navigationController = UINavigationController(rootViewController: controller!)
            
            if cell.reuseIdentifier == "NewPostingTableViewController" {
                slideMenuController.mainViewController?.presentViewController(navigationController, animated: true, completion: nil)
                return
            }
            
            slideMenuController.changeMainViewController(navigationController, close: true)
            
            if cell.reuseIdentifier == "InternalWebViewController" {
                let internalWebViewController = controller as! InternalWebViewController
                internalWebViewController.openWebpageWithUrl("http://break-out.org/worum-gehts/")
            }
        }
    }
    
// MARK: - Button Actions

    @IBAction func addUserpictureButtonPressed(sender: UIButton) {
    }
}
