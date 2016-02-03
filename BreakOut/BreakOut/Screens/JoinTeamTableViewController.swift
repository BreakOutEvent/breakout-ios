//
//  JoinTeamTableViewController.swift
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

class JoinTeamTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var addTeampictureButton: UIButton!
    @IBOutlet weak var teampictureImageView: UIImageView!
    @IBOutlet weak var teamNameTextfield: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var eventSelectionTextfield: UITextField!
    @IBOutlet weak var createTeamButton: UIButton!
    
    @IBOutlet weak var teamInvitationSelectionTextfield: UITextField!
    @IBOutlet weak var joinTeamButton: UIButton!
    
    var eventPicker: UIPickerView! = UIPickerView()
    var eventDataSourceArray: NSArray = NSArray(objects: "Berlin 2016", "München 2016")
    
    var invitationPicker: UIPickerView! = UIPickerView()
    var invitationDataSourceArray: NSArray = NSArray(objects: "Ralle und die Power Ranger", "Fly by Team", "Null oder Null?")
    
    var loadingHUD: MBProgressHUD = MBProgressHUD()
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    //    let validator = Validator()
    
// MARK: - Screen Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add the circle mask to the teampictureImageView
        self.teampictureImageView.layer.cornerRadius = self.teampictureImageView.frame.size.width / 2.0
        self.teampictureImageView.clipsToBounds = true
        
        self.imagePicker.delegate = self
        
        // Set the breakOut Image as Background of the tableview
        let backgroundImageView: UIImageView = UIImageView.init(image: UIImage.init(named: "breakoutDefaultBackground_600x600"))
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.tableView.backgroundView = backgroundImageView
        
        // Set color for placeholder text
        self.teamNameTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("teamname", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("email", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.eventSelectionTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("eventselection", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        
        self.teamInvitationSelectionTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("teaminvitationselection", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        
        // Set localized Button Texts
        self.createTeamButton.setTitle(NSLocalizedString("createTeamButton", comment: ""), forState: UIControlState.Normal)
 
        self.joinTeamButton.setTitle(NSLocalizedString("joinTeamButton", comment: ""), forState: UIControlState.Normal)
        
        self.addTeampictureButton.layer.cornerRadius = self.addTeampictureButton.frame.size.width / 2.0
        
        // Set the Delegates for the EventPicker and connect Picker & Toolbar with the TextField
        self.eventPicker.delegate = self
        self.eventPicker.dataSource = self
        self.eventSelectionTextfield.inputView = self.eventPicker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = Style.mainOrange
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "eventPickerToolbarDoneButtonPressed")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "eventPickerToolbarCancelButtonPressed")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        self.eventSelectionTextfield.inputAccessoryView = toolBar
        
        self.setupInvitationPicker()
    }
    
    func setupInvitationPicker() {
        // Set the Delegates for the InvitationPicker and connect Picker & Toolbar with the TextField
        self.invitationPicker.delegate = self
        self.invitationPicker.dataSource = self
        self.teamInvitationSelectionTextfield.inputView = self.invitationPicker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = Style.mainOrange
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "invitationPickerToolbarDoneButtonPressed")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "invitationPickerToolbarCancelButtonPressed")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        self.teamInvitationSelectionTextfield.inputAccessoryView = toolBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tracking
        Flurry.logEvent("/user/joinTeam", withParameters: nil, timed: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/user/joinTeam", withParameters: nil)
    }
    
// MARK: - Picker Toolbar Functions
    func eventPickerToolbarDoneButtonPressed() {
        self.eventSelectionTextfield.text = self.eventDataSourceArray[self.eventPicker.selectedRowInComponent(0)] as? String
        self.eventSelectionTextfield.resignFirstResponder()
    }
    
    func invitationPickerToolbarDoneButtonPressed() {
        self.teamInvitationSelectionTextfield.text = self.invitationDataSourceArray[self.invitationPicker.selectedRowInComponent(0)] as? String
        self.teamInvitationSelectionTextfield.resignFirstResponder()
    }
    
    func eventPickerToolbarCancelButtonPressed() {
        self.eventSelectionTextfield.resignFirstResponder()
        
        self.eventSelectionTextfield.text = ""
    }
    
    func invitationPickerToolbarCancelButtonPressed() {
        self.teamInvitationSelectionTextfield.resignFirstResponder()
        
        self.teamInvitationSelectionTextfield.text = ""
    }
    
// MARK: - UIPicker DataSource 
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.eventPicker {
            return self.eventDataSourceArray.count
        }else{
            return self.invitationDataSourceArray.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.eventPicker {
            return self.eventDataSourceArray[row] as? String
        }else{
            return self.invitationDataSourceArray[row] as? String
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.eventPicker {
            self.eventSelectionTextfield.text = self.eventDataSourceArray[row] as? String
        }else{
            self.teamInvitationSelectionTextfield.text = self.invitationDataSourceArray[row] as? String
        }
    }
    
// MARK: - Initial Input setup
    
// MARK: - TextField Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.teamNameTextfield {
            // Switch focus to other text field
            self.emailTextField.becomeFirstResponder()
        }else if textField == self.emailTextField{
            self.eventSelectionTextfield.becomeFirstResponder()
        }else if textField == self.eventSelectionTextfield{
            self.view.endEditing(true)
        }
        
        return true
    }
    
// MARK: - Button functions
    
    @IBAction func addTeampictureButtonPressed(sender: UIButton) {
        
        let optionMenu: UIAlertController = UIAlertController(title: nil, message: NSLocalizedString("sourceOfImage", comment: ""), preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let photoLibraryOption = UIAlertAction(title: NSLocalizedString("photoLibrary", comment: ""), style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
            print("from library")
            //shows the library
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .PhotoLibrary
            self.imagePicker.modalPresentationStyle = .Popover
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let cameraOption = UIAlertAction(title: NSLocalizedString("takeAPhoto", comment: ""), style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
            print("take a photo")
            //shows the camera
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .Camera
            self.imagePicker.cameraDevice = .Front
            self.imagePicker.modalPresentationStyle = .Popover
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
        })
        let cancelOption = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancel")
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        //Adding the actions to the action sheet. Here, camera will only show up as an option if the camera is available in the first place.
        optionMenu.addAction(photoLibraryOption)
        optionMenu.addAction(cancelOption)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == true {
            optionMenu.addAction(cameraOption)} else {
            print ("I don't have a camera.")
        }
        
        //Now that the action sheet is set up, we present it.
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func createTeamButtonPressed(sender: UIButton) {
        // Send the participation request to the backend
        self.setupLoadingHUD("loadingJoinTeam")
        self.loadingHUD.show(true)
        //self.startBecomeParticipantRequest()
    }
    
    @IBAction func joinTeamButtonPressed(sender: UIButton) {
    }
    
// MARK: - Image Picker Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let choosenImage: UIImage = image
        
        self.teampictureImageView.image = choosenImage
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        return
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    func setAllInputsToEnabled(enabled: Bool) {
        self.teamNameTextfield.enabled = enabled
        self.emailTextField.enabled = enabled
        self.eventSelectionTextfield.enabled = enabled
    }
    
    
    // MARK: - API Requests
    
    /**
    ???
    
    :param: No parameters
    
    :returns: No return value
    */
    /*func startBecomeParticipantRequest() {
        self.setAllInputsToEnabled(false)
        
        let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL(string: PrivateConstants.backendURL))
        
        let participantParams: NSDictionary = [
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
                
                CurrentUser.sharedInstance.setAttributesWithJSON(response as! NSDictionary)
                
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
        }
    }*/
    
}
