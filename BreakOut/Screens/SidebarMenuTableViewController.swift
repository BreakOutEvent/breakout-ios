//
//  SidebarMenuTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 07.01.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

import StaticDataTableViewController

class SidebarMenuTableViewController: StaticDataTableViewController {
    
    @IBOutlet weak var loginAndRegisterButton: UIButton!
    @IBOutlet weak var userPictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userDistanceRemainingTimeLabel: UILabel!
    @IBOutlet weak var addUserpictureButton: UIButton!
    
    @IBOutlet weak var yourTeamTableViewCell: UITableViewCell!
    @IBOutlet weak var allTeamsTableViewCell: UITableViewCell!
    @IBOutlet weak var newsTableViewCell: UITableViewCell!
    @IBOutlet weak var settingsTableViewCell: UITableViewCell!
    
    var selected: IndexPath?
    
// MARK: - Screen Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add the circle mask to the userpicture
        self.userPictureImageView.layer.cornerRadius = self.userPictureImageView.frame.size.width / 2.0
        self.userPictureImageView.clipsToBounds = true
        
        // Styling the Button for adding a userpicture if non exists.
        self.addUserpictureButton.backgroundColor = UIColor.white
        self.addUserpictureButton.setTitleColor(UIColor.black, for: UIControlState())
        self.addUserpictureButton.layer.cornerRadius = self.addUserpictureButton.frame.size.width / 2.0
        
        self.fillInputsWithCurrentUserInfo()
        
        if self.userPictureImageView.image == nil {
            self.addUserpictureButton.isHidden = false
        } else {
            self.addUserpictureButton.isHidden = true
        }
        
//        self.cell(self.yourTeamTableViewCell, setHidden: true)
        self.cell(self.newsTableViewCell, setHidden: true)
        self.cell(self.allTeamsTableViewCell, setHidden: true)
        self.cell(self.settingsTableViewCell, setHidden: true)
        
        self.loginAndRegisterButton.setTitle("welcomeScreenParticipateButtonLoginAndRegister".local, for: UIControlState())
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAllPostingsTVC), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_NEW_POSTING_CLOSED_WANTS_LIST), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showWelcomeScreen), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_PRESENT_WELCOME_SCREEN), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fillInputsWithCurrentUserInfo()
        tableView.reloadData()
        
        if CurrentUser.shared.isLoggedIn() {
            self.userPictureImageView.isHidden = false
            self.usernameLabel.isHidden = false
            self.userDistanceRemainingTimeLabel.isHidden = false
            self.loginAndRegisterButton.isHidden = true
        }else{
            self.userPictureImageView.isHidden = true
            self.usernameLabel.isHidden = true
            self.userDistanceRemainingTimeLabel.isHidden = true
            self.loginAndRegisterButton.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Tracking
        //Flurry.logEvent("/user/profile", withParameters: nil, timed: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Tracking
        //Flurry.endTimedEvent("/user/profile", withParameters: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.NOTIFICATION_NEW_POSTING_CLOSED_WANTS_LIST), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.NOTIFICATION_PRESENT_WELCOME_SCREEN), object: nil)
    }
    
    func fillInputsWithCurrentUserInfo() {
        self.usernameLabel.text = CurrentUser.shared.username()
        
        self.userPictureImageView.image = CurrentUser.shared.picture
        if self.userPictureImageView.image != nil {
            self.addUserpictureButton.isHidden = true
        }
    }
    
    func showWelcomeScreen() {
        if let slideMenuController = self.slideMenuController() {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeScreenViewController")
            slideMenuController.changeMainViewController(controller!, close: true)
        }
    }
    
    func showAllPostingsTVC() {
        if let slideMenuController = self.slideMenuController() {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "AllPostingsTableViewController")
        
            let navigationController = UINavigationController(rootViewController: controller!)
        
            slideMenuController.changeMainViewController(navigationController, close: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 && indexPath.row == 1 && CurrentUser.shared.currentTeamId() < 0 {
            return false
        } else if indexPath.section == 1 && indexPath.row == 2 && !CurrentUser.shared.isLoggedIn() {
            return false
        } else if indexPath.section == 1 && indexPath.row == 3 && CurrentUser.shared.currentTeamId() < 0 {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 && CurrentUser.shared.currentTeamId() < 0 {
            cell.alpha = 0.5
        } else if indexPath.section == 1 && indexPath.row == 2 && !CurrentUser.shared.isLoggedIn() {
            cell.alpha = 0.5
        } else if indexPath.section == 1 && indexPath.row == 3 && CurrentUser.shared.currentTeamId() < 0 {
            cell.alpha = 0.5
        } else {
            cell.alpha = 1.0
        }
        if indexPath.section != 0 {
            if indexPath == selected {
                cell.set(color: .mainOrange)
            } else {
                cell.set(color: .black)
            }
        }
    }
    
    func viewController(for identifier: String) -> UIViewController! {
        let controller = storyboard!.instantiateViewController(withIdentifier: identifier)
        if let type = type(of: controller) as? PersistentViewController.Type {
            return type.viewController(using: controller)
        }
        return controller
    }
    
// MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        if indexPath != IndexPath(row: 1, section: 1) {
            selected = indexPath
        }
        if indexPath.section == 0 {
            if CurrentUser.shared.isLoggedIn() {
                selected = IndexPath(row: 2, section: 1)
            } else {
                selected = IndexPath(row: 0, section: 0)
            }
        }
        
        if let slideMenuController = self.slideMenuController() {
            let controller = viewController(for: cell.reuseIdentifier!)
            
            let navigationController = UINavigationController(rootViewController: controller!)
            
            if cell.reuseIdentifier == "NewPostingTableViewController" {
                slideMenuController.mainViewController?.present(navigationController, animated: true, completion: nil)
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

    @IBAction func addUserpictureButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN), object: nil)
    }
}
