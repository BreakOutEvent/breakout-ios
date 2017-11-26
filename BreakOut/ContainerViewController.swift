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
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeScreenViewController") {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "SidebarMenuTableViewController") {
            self.leftViewController = controller
        }
        
        SlideMenuOptions.contentViewScale = 1.0
        
        super.awakeFromNib()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        // Check UserDefaults for already logged in user
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "userDictionary") == nil {
            // User is NOT logged in
        } else {
            CurrentUser.shared.downloadUserData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentLoginScreen), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN), object: nil)
    }
    
// MARK: - Helper Functions
    func presentLoginScreen() {
        BreakOut.shared.logout()
        CurrentUser.resetUser()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginRegisterViewController: LoginRegisterViewController = storyboard.instantiateViewController(withIdentifier: "LoginRegisterViewController") as! LoginRegisterViewController
        
        self.present(loginRegisterViewController, animated: true, completion: nil)
    }

}
