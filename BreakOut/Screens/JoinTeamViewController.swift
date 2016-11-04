//
//  JoinTeamViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 25.01.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

import MBProgressHUD
import SpinKit

import LECropPictureViewController

import AFOAuth2Manager

class JoinTeamViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    
    @IBOutlet weak var invitationViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var invitationButton: UIButton!
    @IBOutlet weak var teamInvitationSelectionTextfield: UITextField!
    @IBOutlet weak var joinTeamButton: UIButton!
    
    
    
    var invitationPicker: UIPickerView! = UIPickerView()
    var invitationDataSourceArray: NSArray = NSArray(objects: "Ralle und die Power Ranger", "Fly by Team", "Null oder Null?")
    
    var loadingHUD: MBProgressHUD = MBProgressHUD()
    
    var createTeamTableViewController: CreateTeamTableViewController?
    
    //    let validator = Validator()
    
// MARK: - Screen Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set color for placeholder text
        
        /*self.teamInvitationSelectionTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("teaminvitationselection", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        
        // Set localized Button Texts
 
        self.joinTeamButton.setTitle(NSLocalizedString("joinTeamButton", comment: ""), forState: UIControlState.Normal)
        
        self.setupInvitationPicker()*/
        
        self.invitationViewTopConstraint.constant = self.view.frame.size.height - self.invitationButton.frame.size.height
        
        
    }
    
    func setupInvitationPicker() {
        // Set the Delegates for the InvitationPicker and connect Picker & Toolbar with the TextField
        self.invitationPicker.delegate = self
        self.invitationPicker.dataSource = self
        self.teamInvitationSelectionTextfield.inputView = self.invitationPicker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Style.mainOrange
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(JoinTeamViewController.invitationPickerToolbarDoneButtonPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(JoinTeamViewController.invitationPickerToolbarCancelButtonPressed))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.teamInvitationSelectionTextfield.inputAccessoryView = toolBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Tracking
        Flurry.logEvent("/user/joinTeam", withParameters: nil, timed: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/user/joinTeam", withParameters: nil)
    }
    
// MARK: - Picker Toolbar Functions
    
    func invitationPickerToolbarDoneButtonPressed() {
        self.teamInvitationSelectionTextfield.text = self.invitationDataSourceArray[self.invitationPicker.selectedRow(inComponent: 0)] as? String
        self.teamInvitationSelectionTextfield.resignFirstResponder()
    }
    
    func invitationPickerToolbarCancelButtonPressed() {
        self.teamInvitationSelectionTextfield.resignFirstResponder()
        
        self.teamInvitationSelectionTextfield.text = ""
    }
    
// MARK: - UIPicker DataSource 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.invitationDataSourceArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.invitationDataSourceArray[row] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.teamInvitationSelectionTextfield.text = self.invitationDataSourceArray[row] as? String
    }
    
// MARK: - Initial Input setup
    
// MARK: - TextField Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
// MARK: - Button functions
    
    @IBAction func invitationButtonPressed(_ sender: UIButton) {
        self.view.layoutIfNeeded()
        if self.invitationViewTopConstraint.constant <= 100.0 {
            // InvitationsView is visible -> Hide it
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.invitationViewTopConstraint.constant = self.view.frame.size.height - self.invitationButton.frame.size.height
                self.view.layoutIfNeeded()
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.invitationViewTopConstraint.constant = 0.0 + self.topLayoutGuide.length
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func joinTeamButtonPressed(_ sender: UIButton) {
        self.setupLoadingHUD("loadingJoinTeam")
        self.loadingHUD.show(true)
    }
    
// MARK: - Helper Functions
    func setupLoadingHUD(_ localizedKey: String) {
        let spinner: RTSpinKitView = RTSpinKitView(style: RTSpinKitViewStyle.style9CubeGrid, color: UIColor.white, spinnerSize: 37.0)
        self.loadingHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loadingHUD.isSquare = true
        self.loadingHUD.mode = MBProgressHUDMode.customView
        self.loadingHUD.customView = spinner
        self.loadingHUD.labelText = NSLocalizedString(localizedKey, comment: "loading")
        spinner.startAnimating()
    }
    
   
// TODO: Move these to the Synchronizer
// MARK: - API Requests
    
    /**
    ???
    
    :param: No parameters
    
    :returns: No return value
    */
    func startCreateTeamRequest() {
        //self.setAllInputsToEnabled(false)
        
//        let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL(string: PrivateConstants.backendURL))
        
        /*let participantParams: NSDictionary = [
            "emergencynumber": self.emergencyNumberTextfield.text!,
            "hometown": self.hometownTextfield.text!,
            "phonenumber": self.phonenumberTextfield.text!,
            "tshirtsize": self.shirtSizeTextfield.text!
        ]
        let params: NSDictionary = [
            "firstname":self.firstNameTextfield.text!,
            "lastname":self.lastNameTextfield.text!,
            "email":self.emailTextField.text!,
            "gender":"unknown",
            "participant": participantParams
        ]
        
        requestManager.requestSerializer = AFJSONRequestSerializer()
        
        // Get user id from NSUserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        let userID: String = (defaults.objectForKey("userID") as! NSNumber).stringValue
        
        requestManager.requestSerializer.setAuthorizationHeaderFieldWithCredential( AFOAuthCredential.retrieveCredentialWithIdentifier("apiCredentials") )
        
        requestManager.PUT(String(format: "user/%@/", userID), parameters: params,
            success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                print("Become Participant Response: ")
                print(response)
                
                CurrentUser.shared.setAttributesWithJSON(response as! NSDictionary)
                
                // Tracking
                Flurry.logEvent("/user/becomeParticipant/completed_successful")
                
                // Activate Inputs again
                self.setAllInputsToEnabled(true)
                
                self.loadingHUD.hide(true)
            })
            { (operation: AFHTTPRequestOperation?, error:NSError) -> Void in
                print("Registration Error: ")
                print(error)
                
                // TODO: Show detailed errors to the user
                
                // Tracking
                Flurry.logEvent("/user/becomeParticipant/completed_error")
                
                // Activate Inputs again
                self.setAllInputsToEnabled(true)
                
                self.loadingHUD.hide(true)
        }*/
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed_CreateTeamTableViewController" {
            self.createTeamTableViewController = segue.destination as! CreateTeamTableViewController
        }
    }
}
