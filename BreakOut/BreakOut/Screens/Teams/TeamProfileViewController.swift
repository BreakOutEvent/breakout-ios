//
//  TeamProfileViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 05.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

class TeamProfileViewController: UIViewController {

    @IBOutlet weak var subMenuView: UIView!
    @IBOutlet weak var postingsTableViewControllerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Style the navigation bar
        self.navigationController!.navigationBar.translucent = false
        self.navigationController!.navigationBar.barTintColor = Style.mainOrange
        self.navigationController!.navigationBar.backgroundColor = Style.mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        self.title = "Team Name"
        
        // Create right button for navigation item
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "editTeamInfo")
        
        // Create two buttons for the navigation item
        navigationItem.rightBarButtonItem = rightButton
        
        let barButtonImage = UIImage(named: "help_Icon")
        if barButtonImage != nil {
            self.addLeftBarButtonWithImage(barButtonImage!)
        }
        
        self.navigationController?.navigationBar.alpha = 0.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showSubmenu() {
        self.subMenuView.hidden = false
    }
    
    func hideSubmenu() {
        self.subMenuView.hidden = true
    }
    
    @IBAction func showTeamDescription(sender: AnyObject) {
        self.subMenuView.frame.origin.y = self.view.frame.size.height - self.subMenuView.frame.size.height
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.postingsTableViewControllerContainer.frame.origin.y = self.view.frame.size.height
            }) { (done: Bool) -> Void in
                self.showSubmenu()
        }
    }
    @IBAction func swipeUpInSubMenu(sender: AnyObject) {
        self.hideSubmenu()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.postingsTableViewControllerContainer.frame.origin.y = 0
            }) { (done: Bool) -> Void in
                self.subMenuView.frame.origin.y = (self.navigationController?.navigationBar.frame.size.height)!
        }
    }

// MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EmbedTeamProfilePostingsTableViewController" {
            let destinationController:TeamProfilePostingsTableViewController = segue.destinationViewController as! TeamProfilePostingsTableViewController
            destinationController.parentTeamProfileViewController = self
        }
    }
}
