//
//  BecomeParticipantTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 10.01.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

import MBProgressHUD
import SpinKit

class BecomeParticipantTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var addUserpictureButton: UIButton!
    @IBOutlet weak var userpictureImageView: UIImageView!
    @IBOutlet weak var firstNameTextfield: UITextField!
    @IBOutlet weak var secondNameTextfield: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var shirtSizeTextfield: UITextField!
    @IBOutlet weak var startCityTextfield: UITextField!
    @IBOutlet weak var phonenumberTextfield: UITextField!
    @IBOutlet weak var emergencyNumberTextfield: UITextField!
    @IBOutlet weak var participateButton: UIButton!
    
    var loadingHUD: MBProgressHUD = MBProgressHUD()
    
// MARK: - Screen Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the breakOut Image as Background of the tableview
        let backgroundImageView: UIImageView = UIImageView.init(image: UIImage.init(named: "breakoutDefaultBackground_600x600"))
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.tableView.backgroundView = backgroundImageView
        
        // Set color for placeholder text
        self.firstNameTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("firstname", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.secondNameTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("secondname", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("email", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        
        // Set localized Button Texts
        self.participateButton.setTitle(NSLocalizedString("participateButton", comment: ""), forState: UIControlState.Normal)
        
        self.addUserpictureButton.layer.cornerRadius = self.addUserpictureButton.frame.size.width / 2.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tracking
        Flurry.logEvent("/becomeParticipant/user", withParameters: nil, timed: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/becomeParticipant/user", withParameters: nil)
    }
    
// MARK: - TextField Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.firstNameTextfield {
            // Switch focus to other text field
            self.secondNameTextfield.becomeFirstResponder()
        }else if textField == self.secondNameTextfield{
            self.emailTextField.becomeFirstResponder()
        }else if textField == self.emailTextField{
            self.shirtSizeTextfield.becomeFirstResponder()
        }else if textField == self.shirtSizeTextfield{
            self.startCityTextfield.becomeFirstResponder()
        }else if textField == self.startCityTextfield{
            self.phonenumberTextfield.becomeFirstResponder()
        }else if textField == self.phonenumberTextfield{
            self.emergencyNumberTextfield.becomeFirstResponder()
        }else if textField == self.emergencyNumberTextfield{
            self.view.endEditing(true)
        }
        
        return true
    }
    
// MARK: - Button functions
    
    @IBAction func addUserpictureButtonPressed(sender: UIButton) {
    }
    
    @IBAction func participateButtonPressed(sender: UIButton) {
        // Send the participation request to the backend
        self.setupLoadingHUD("loadingParticipant")
        self.loadingHUD.show(true)
    }
    
    
// MARK: - Helper Functions
    func setupLoadingHUD(localizedKey: String) {
        let spinner: RTSpinKitView = RTSpinKitView(style: RTSpinKitViewStyle.StyleChasingDots, color: UIColor.whiteColor(), spinnerSize: 37.0)
        self.loadingHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.loadingHUD.square = true
        self.loadingHUD.mode = MBProgressHUDMode.CustomView
        self.loadingHUD.customView = spinner
        self.loadingHUD.labelText = NSLocalizedString(localizedKey, comment: "loading")
        spinner.startAnimating()
    }
}
