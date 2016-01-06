//
//  UserProfileViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 28.12.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

class UserProfileTableViewController: UITableViewController {

    @IBOutlet weak var participateButton: UIButton!

// MARK: - Screen Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tracking
        Flurry.logEvent("/user/profile", withParameters: nil, timed: true)
        
        // Check UserDefaults for already logged in user
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("userAccessToken") == nil {
            self.presentLoginScreen()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/user/profile", withParameters: nil)
    }
    
// MARK: - Helper Functions
    func presentLoginScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginRegisterViewController: LoginRegisterViewController = storyboard.instantiateViewControllerWithIdentifier("LoginRegisterViewController") as! LoginRegisterViewController
        
        self.presentViewController(loginRegisterViewController, animated: true, completion: nil)
    }
    
// MARK: - Button Actions
    @IBAction func participateButtonPressed(sender: UIButton) {
    }
    
    @IBAction func logoutButtonPressed(sender: UIButton) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nil, forKey: "userEMail")
        defaults.setObject(nil, forKey: "userAccessToken")
        
        self.presentLoginScreen()
    }
}
