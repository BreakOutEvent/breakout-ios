//
//  ContainerViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 03.01.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

import SlideMenuControllerSwift

class ContainerViewController: SlideMenuController {
    
    override func awakeFromNib() {
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("WelcomeScreenViewController") {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("SidebarMenuTableViewController") {
            self.leftViewController = controller
        }
        
        SlideMenuOptions.contentViewScale = 1.0
        
        super.awakeFromNib()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Check UserDefaults for already logged in user
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("userDictionary") == nil {
            self.presentLoginScreen()
        }else{
            CurrentUser.sharedInstance.downloadUserData()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentLoginScreen", name: Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN, object: nil)
    }
    
// MARK: - Helper Functions
    func presentLoginScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginRegisterViewController: LoginRegisterViewController = storyboard.instantiateViewControllerWithIdentifier("LoginRegisterViewController") as! LoginRegisterViewController
        
        self.presentViewController(loginRegisterViewController, animated: true, completion: nil)
    }

}
