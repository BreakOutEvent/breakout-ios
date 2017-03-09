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
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = .mainOrange
        self.navigationController!.navigationBar.backgroundColor = .mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.title = "Team Name"
        
        // Create right button for navigation item
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: "editTeamInfo")
        
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
        self.subMenuSelectionBarView.backgroundColor = .mainOrange
        self.subMenuView.addSubview(self.subMenuSelectionBarView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.animateSubMenuSelectionBarViewToButton(self.subMenuPostingsButton)
        self.subMenuPostingsButton.isSelected = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showSubmenu() {
        self.subMenuView.isHidden = false
    }
    
    func hideSubmenu() {
        self.subMenuView.isHidden = true
    }
    
    @IBAction func showTeamDescription(_ sender: AnyObject) {
        self.subMenuView.frame.origin.y = self.view.frame.size.height - self.subMenuView.frame.size.height
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.postingsTableViewControllerContainer.frame.origin.y = self.view.frame.size.height
            }, completion: { (done: Bool) -> Void in
                self.showSubmenu()
        }) 
    }
    @IBAction func swipeUpInSubMenu(_ sender: AnyObject) {
        self.hideSubmenu()
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.postingsTableViewControllerContainer.frame.origin.y = 0
            }, completion: { (done: Bool) -> Void in
                self.subMenuView.frame.origin.y = (self.navigationController?.navigationBar.frame.size.height)!
        }) 
    }
    
// MARK: - SubMenu Button Functions
    
    @IBAction func subMenuPostingsButtonPressed(_ sender: UIButton) {
        self.deselectAllSubMenuButtons()
        sender.isSelected = true
        self.animateSubMenuSelectionBarViewToButton(sender)
    }
    
    @IBAction func subMenuMapButtonPressed(_ sender: UIButton) {
        self.deselectAllSubMenuButtons()
        sender.isSelected = true
        self.animateSubMenuSelectionBarViewToButton(sender)
    }
    
    func deselectAllSubMenuButtons() {
        self.subMenuPostingsButton.isSelected = false
        self.subMenuMapButton.isSelected = false
    }

    func animateSubMenuSelectionBarViewToButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.subMenuSelectionBarView.frame.origin.x = button.frame.origin.x
            self.subMenuSelectionBarView.frame.size.width = button.frame.size.width
            }, completion: { (finished: Bool) -> Void in
                //
        }) 
    }
// MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EmbedTeamProfilePostingsTableViewController" {
            let destinationController:TeamProfilePostingsTableViewController = segue.destination as! TeamProfilePostingsTableViewController
            destinationController.parentTeamProfileViewController = self
        }
    }
}
