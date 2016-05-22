//
//  WelcomeScreenViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 05.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

class WelcomeScreenViewController: UIViewController {

    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var participateButton: UIButton!
    
    var timer: NSTimer?
    var eventStartDate: NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default

        // Do any additional setup after loading the view.
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("eventStartTimestamp") != nil {
            self.eventStartDate = NSDate(timeIntervalSince1970: (defaults.objectForKey("eventStartTimestamp") as! Double))
        }
        
        self.headlineLabel.text = NSLocalizedString("welcomeScreenHeadline", comment: "")
        self.descriptionTextLabel.text = NSLocalizedString("welcomeScreenDescriptionText", comment: "")
        
        if CurrentUser.sharedInstance.isLoggedIn() {
            // User is logged in
            self.participateButton.setTitle(NSLocalizedString("welcomeScreenParticipateButtonShareLocation", comment: ""), forState: UIControlState.Normal)
        }else{
            // User is not logged in
            self.participateButton.setTitle(NSLocalizedString("welcomeScreenParticipateButtonLoginAndRegister", comment: ""), forState: UIControlState.Normal)
        }
        
        
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    func updateCountdown() {
        if self.eventStartDate != nil {
            self.headlineLabel.text = self.eventStartDate!.toNaturalString(NSDate())
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tracking
        Flurry.logEvent("/welcomeScreen", timed: true)
        
        if CurrentUser.sharedInstance.isLoggedIn() && CurrentUser.sharedInstance.currentTeamId() < 0 {
            self.participateButton.enabled = false
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/welcomeScreen", withParameters: nil)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
// MARK: - Button Actions
    
    @IBAction func participateButtonPressed(sender: UIButton) {
        /*let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let becomeParticipantTVC: BecomeParticipantTableViewController = storyboard.instantiateViewControllerWithIdentifier("BecomeParticipantTableViewController") as! BecomeParticipantTableViewController
        
        self.presentViewController(becomeParticipantTVC, animated: true, completion: nil)*/
        
        if CurrentUser.sharedInstance.isLoggedIn() {
            // User is logged in -> Show NewPostingsTVC
            if let slideMenuController = self.slideMenuController() {
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewPostingTableViewController")
                
                let navigationController = UINavigationController(rootViewController: controller!)
                
                slideMenuController.mainViewController?.presentViewController(navigationController, animated: true, completion: nil)
            }
        }else{
            // User is NOT logged in -> show login screen
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN, object: nil)
        }
        
        
    }
    
    @IBAction func menuButtonPressed(sender: UIButton) {
        self.slideMenuController()?.toggleLeft()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
