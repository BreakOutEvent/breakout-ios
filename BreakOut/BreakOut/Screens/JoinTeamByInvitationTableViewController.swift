//
//  JoinTeamByInvitationTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 04.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

class JoinTeamByInvitationTableViewController: UITableViewController {
    
    @IBOutlet weak var teamInvitationSelectionTextfield: UITextField!
    @IBOutlet weak var joinTeamButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: - Button functions 
    
    @IBAction func joinTeamButtonPressed(sender: UIButton) {
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
