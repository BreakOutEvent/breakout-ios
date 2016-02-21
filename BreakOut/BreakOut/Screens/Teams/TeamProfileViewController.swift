//
//  TeamProfileViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 05.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

class TeamProfileViewController: UIViewController {

    @IBOutlet weak var subMenuPostingsButton: UIButton!
    @IBOutlet weak var subMenuMapButton: UIButton!
    @IBOutlet weak var subMenuView: UIView!
    var subMenuSelectionBarView: UIView = UIView()
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
        
        self.subMenuSelectionBarView = UIView()
        self.subMenuSelectionBarView.frame.origin.x = 0.0
        self.subMenuSelectionBarView.frame.origin.y = self.subMenuPostingsButton.frame.size.height-2.0
        self.subMenuSelectionBarView.frame.size.height = 2.0
        self.subMenuSelectionBarView.backgroundColor = Style.mainOrange
        self.subMenuView.addSubview(self.subMenuSelectionBarView)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.animateSubMenuSelectionBarViewToButton(self.subMenuPostingsButton)
        self.subMenuPostingsButton.selected = true
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
    
// MARK: - SubMenu Button Functions
    
    @IBAction func subMenuPostingsButtonPressed(sender: UIButton) {
        self.deselectAllSubMenuButtons()
        sender.selected = true
        self.animateSubMenuSelectionBarViewToButton(sender)
    }
    
    @IBAction func subMenuMapButtonPressed(sender: UIButton) {
        self.deselectAllSubMenuButtons()
        sender.selected = true
        self.animateSubMenuSelectionBarViewToButton(sender)
    }
    
    func deselectAllSubMenuButtons() {
        self.subMenuPostingsButton.selected = false
        self.subMenuMapButton.selected = false
    }

    func animateSubMenuSelectionBarViewToButton(button: UIButton) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.subMenuSelectionBarView.frame.origin.x = button.frame.origin.x
            self.subMenuSelectionBarView.frame.size.width = button.frame.size.width
            }) { (finished: Bool) -> Void in
                //
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
