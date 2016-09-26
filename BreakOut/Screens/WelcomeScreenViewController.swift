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
    
    var timer: Timer?
    var eventStartDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default

        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "eventStartTimestamp") != nil {
            self.eventStartDate = Date(timeIntervalSince1970: (defaults.object(forKey: "eventStartTimestamp") as! Double))
        }
        
        self.headlineLabel.text = NSLocalizedString("welcomeScreenHeadline", comment: "")
        self.descriptionTextLabel.text = NSLocalizedString("welcomeScreenDescriptionText", comment: "")
        
        if CurrentUser.shared.isLoggedIn() {
            // User is logged in
            self.participateButton.setTitle(NSLocalizedString("welcomeScreenParticipateButtonShareLocation", comment: ""), for: UIControlState())
        }else{
            // User is not logged in
            self.participateButton.setTitle(NSLocalizedString("welcomeScreenParticipateButtonLoginAndRegister", comment: ""), for: UIControlState())
        }
        
        
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    func updateCountdown() {
        if self.eventStartDate != nil {
            self.headlineLabel.text = self.eventStartDate!.toString()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Tracking
        Flurry.logEvent("/welcomeScreen", timed: true)
        
        if CurrentUser.shared.isLoggedIn() && CurrentUser.shared.currentTeamId() < 0 {
            self.participateButton.isEnabled = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/welcomeScreen", withParameters: nil)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
// MARK: - Button Actions
    
    @IBAction func participateButtonPressed(_ sender: UIButton) {
        /*let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let becomeParticipantTVC: BecomeParticipantTableViewController = storyboard.instantiateViewControllerWithIdentifier("BecomeParticipantTableViewController") as! BecomeParticipantTableViewController
        
        self.presentViewController(becomeParticipantTVC, animated: true, completion: nil)*/
        
        if CurrentUser.shared.isLoggedIn() {
            // User is logged in -> Show NewPostingsTVC
            if let slideMenuController = self.slideMenuController() {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewPostingTableViewController")
                
                let navigationController = UINavigationController(rootViewController: controller!)
                
                slideMenuController.mainViewController?.present(navigationController, animated: true, completion: nil)
            }
        }else{
            // User is NOT logged in -> show login screen
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN), object: nil)
        }
        
        
    }
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
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
