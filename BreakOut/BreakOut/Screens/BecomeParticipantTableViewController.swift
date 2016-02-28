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

import LECropPictureViewController

import AFOAuth2Manager

class BecomeParticipantTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var addUserpictureButton: UIButton!
    @IBOutlet weak var userpictureImageView: UIImageView!
    @IBOutlet weak var firstNameTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var birthdayTextField: UITextField!
    var birthdayDatePicker: UIDatePicker! = UIDatePicker()
    
    @IBOutlet weak var shirtSizeTextfield: UITextField!
    var shirtSizePicker: UIPickerView! = UIPickerView()
    var shirtSizeDataSourceArray: NSArray = NSArray(objects: "S", "M", "L")
    
    @IBOutlet weak var phonenumberTextfield: UITextField!
    @IBOutlet weak var emergencyNumberTextfield: UITextField!
    @IBOutlet weak var participateButton: UIButton!
    @IBOutlet weak var participateCellContentView: UIView!
    
    var loadingHUD: MBProgressHUD = MBProgressHUD()
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    var currentTextFieldWithFirstResponder: UITextField?
    
//    let validator = Validator()
    
// MARK: - Screen Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add the circle mask to the userpicture
        self.userpictureImageView.layer.cornerRadius = self.userpictureImageView.frame.size.width / 2.0
        self.userpictureImageView.clipsToBounds = true
        
        self.imagePicker.delegate = self
        
        // Set the breakOut Image as Background of the tableview
        let backgroundImageView: UIImageView = UIImageView.init(image: UIImage.init(named: "breakoutDefaultBackground_600x600"))
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.tableView.backgroundView = backgroundImageView
        
        // Set color for placeholder text
        self.firstNameTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("firstname", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.lastNameTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("lastname", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("email", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.shirtSizeTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("shirtSize", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.birthdayTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("birthday", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.phonenumberTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("phonenumber", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.emergencyNumberTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("emergencyNumber", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        
        // Set localized Button Texts
        self.participateButton.setTitle(NSLocalizedString("participateButton", comment: ""), forState: UIControlState.Normal)
        
        self.addUserpictureButton.layer.cornerRadius = self.addUserpictureButton.frame.size.width / 2.0
        
        // Setup the PickerViews as Inputs for Birthday and T-Shirt size
        self.setupBirthdayDatePicker()
        self.setupShirtSizePicker()
        
        self.addSimpleDoneToolbarToTextField(self.phonenumberTextfield)
        self.addSimpleDoneToolbarToTextField(self.emergencyNumberTextfield)
        
        self.fillInputsWithCurrentUserInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tracking
        Flurry.logEvent("/user/becomeParticipant", withParameters: nil, timed: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/user/becomeParticipant", withParameters: nil)
    }
    
// MARK: - Initial Input setup 
    
    func fillInputsWithCurrentUserInfo() {
        self.firstNameTextfield.text = CurrentUser.sharedInstance.firstname
        self.lastNameTextfield.text = CurrentUser.sharedInstance.lastname
        self.emailTextField.text = CurrentUser.sharedInstance.email
        self.genderSegmentedControl.selectedSegmentIndex = CurrentUser.sharedInstance.genderAsInt()
    }
    
// MARK: - Picker Setup & Button functions
    
    // MARK: Birthday Picker
    
    func setupBirthdayDatePicker() {
        self.birthdayDatePicker.datePickerMode = UIDatePickerMode.Date
        self.birthdayTextField.inputView = self.birthdayDatePicker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = Style.mainOrange
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "birthdayDatePickerToolbarDoneButtonPressed")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        self.birthdayTextField.inputAccessoryView = toolBar
    }
    
    func birthdayDatePickerToolbarDoneButtonPressed() {
        self.birthdayTextField.text = self.birthdayDatePicker.date.description
        self.birthdayTextField.resignFirstResponder()
    }
    
    // MARK: T-Shirt size Picker
    
    func addSimpleDoneToolbarToTextField(textfield: UITextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = Style.mainOrange
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "textFieldToolbarDoneButtonPressed:")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        textfield.inputAccessoryView = toolBar
    }
    
    func textFieldToolbarDoneButtonPressed(sender: UIBarButtonItem) {
        if self.currentTextFieldWithFirstResponder != nil {
            self.currentTextFieldWithFirstResponder?.resignFirstResponder()
        }
    }
    
    func setupShirtSizePicker() {
        // Set the Delegates for the InvitationPicker and connect Picker & Toolbar with the TextField
        self.shirtSizePicker.delegate = self
        self.shirtSizePicker.dataSource = self
        self.shirtSizeTextfield.inputView = self.shirtSizePicker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = Style.mainOrange
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "shirtSizePickerToolbarDoneButtonPressed")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "shirtSizePickerToolbarCancelButtonPressed")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        self.shirtSizeTextfield.inputAccessoryView = toolBar
    }
    
    func shirtSizePickerToolbarDoneButtonPressed() {
        self.shirtSizeTextfield.text = self.shirtSizeDataSourceArray[self.shirtSizePicker.selectedRowInComponent(0)] as? String
        self.shirtSizeTextfield.resignFirstResponder()
    }
    
    // MARK: T-Shirt size Picker DataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.shirtSizeDataSourceArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.shirtSizeDataSourceArray[row] as? String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.shirtSizeTextfield.text = self.shirtSizeDataSourceArray[row] as? String
    }
    
// MARK: - TextField Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.firstNameTextfield {
            // Switch focus to other text field
            self.getGenderByFirstname()
            self.lastNameTextfield.becomeFirstResponder()
        }else if textField == self.lastNameTextfield{
            self.emailTextField.becomeFirstResponder()
        }else if textField == self.emailTextField{
            self.birthdayTextField.becomeFirstResponder()
        }else if textField == self.birthdayTextField{
            self.shirtSizeTextfield.becomeFirstResponder()
        }else if textField == self.shirtSizeTextfield{
            self.phonenumberTextfield.becomeFirstResponder()
        }else if textField == self.phonenumberTextfield{
            self.emergencyNumberTextfield.becomeFirstResponder()
        }else if textField == self.emergencyNumberTextfield{
            self.view.endEditing(true)
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.currentTextFieldWithFirstResponder = textField
    }
    
// MARK: - Button functions
    
    @IBAction func addUserpictureButtonPressed(sender: UIButton) {
        
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
    
    @IBAction func participateButtonPressed(sender: UIButton) {
        self.performSegueWithIdentifier("showJoinTeamViewController", sender: self)
        return
        
        if self.allInputsAreFilled() {
            // Send the participation request to the backend
            self.setupLoadingHUD("loadingParticipant")
            self.loadingHUD.show(true)
            self.startBecomeParticipantRequest()
        }
    }
    
// MARK: - Image Picker Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let choosenImage: UIImage = image
        
        self.userpictureImageView.image = choosenImage
        
        self.addUserpictureButton.hidden = true
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        return
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
// MARK: - Helper Functions
    func setupLoadingHUD(localizedKey: String) {
        let spinner: RTSpinKitView = RTSpinKitView(style: RTSpinKitViewStyle.Style9CubeGrid, color: UIColor.whiteColor(), spinnerSize: 37.0)
        self.loadingHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.loadingHUD.square = true
        self.loadingHUD.mode = MBProgressHUDMode.CustomView
        self.loadingHUD.customView = spinner
        self.loadingHUD.labelText = NSLocalizedString(localizedKey, comment: "loading")
        spinner.startAnimating()
    }
    
    func setupErrorHUD(localizedKey: String) {
        self.loadingHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.loadingHUD.square = false
        self.loadingHUD.mode = MBProgressHUDMode.CustomView
        self.loadingHUD.labelText = NSLocalizedString(localizedKey, comment: "loading")
    }
    
    func setAllInputsToEnabled(enabled: Bool) {
        self.firstNameTextfield.enabled = enabled
        self.lastNameTextfield.enabled = enabled
        self.emailTextField.enabled = enabled
        self.genderSegmentedControl.enabled = enabled
        self.shirtSizeTextfield.enabled = enabled
        self.birthdayTextField.enabled = enabled
        self.phonenumberTextfield.enabled = enabled
        self.emergencyNumberTextfield.enabled = enabled
    }
    
    func allInputsAreFilled() -> Bool {
        var allInputsAreFilled = true
        
        if self.firstNameTextfield.text == "" {
            allInputsAreFilled = false
        }
        if self.lastNameTextfield.text == "" {
            allInputsAreFilled = false
        }
        if self.emailTextField.text == "" {
            allInputsAreFilled = false
        }
        if self.genderSegmentedControl.selectedSegmentIndex<0 {
            allInputsAreFilled = false
        }
        if self.birthdayTextField.text == "" {
            allInputsAreFilled = false
        }
        if self.shirtSizeTextfield.text == "" {
            allInputsAreFilled = false
        }
        if self.phonenumberTextfield.text == "" {
            allInputsAreFilled = false
        }
        if self.emergencyNumberTextfield.text == "" {
            allInputsAreFilled = false
        }
        
        if allInputsAreFilled == false {
            /*if let alertPopover: BOPopoverViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BOPopoverViewController") as? BOPopoverViewController {
                self.participateCellContentView.addSubview(alertPopover.view)
                alertPopover.messageLabel.text = "Bevor du Teilnehmer werden kannst müssen alle Eingabefelder ausgefüllt sein!"
                
                alertPopover.messageLabel.sizeToFit()
                alertPopover.view.frame.origin.x = 20.0
                alertPopover.view.frame.size.width = self.view.frame.size.width - 40.0
                alertPopover.view.frame.size.height = alertPopover.messageLabel.frame.height + 20.0 + 30.0
                alertPopover.view.frame.origin.y = self.participateButton.frame.origin.y - 10.0 - alertPopover.view.frame.size.height
                
                alertPopover.view.setNeedsLayout()
                
                
                
                //alertPopover.view.addConstraint(NSLayoutConstraint(item: alertPopover.view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.participateButton, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 20.0))
                //alertPopover.view.addConstraint(NSLayoutConstraint(item: alertPopover.view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 20.0))
                //alertPopover.view.addConstraint(NSLayoutConstraint(item: alertPopover.view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 20.0))
                
            }*/
            self.setupErrorHUD("Alle Felder müssen ausgefüllt sein!")
            self.loadingHUD.hide(true, afterDelay: 3.0)
            return false
        }
        
        return true
    }
    
    func getGenderByFirstname() {
        let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL(string: "https://api.genderize.io/"))
        
        let params: NSDictionary = ["name":self.firstNameTextfield.text!]
        
        requestManager.requestSerializer = AFJSONRequestSerializer()
        
        requestManager.GET("", parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                // Successful retrival of name attributes
                let dict: NSDictionary = response as! NSDictionary
                if dict.valueForKey("gender") as! String == "male" {
                    self.genderSegmentedControl.selectedSegmentIndex = 0
                }else{
                    self.genderSegmentedControl.selectedSegmentIndex = 1
                }
            }) { (operation:AFHTTPRequestOperation?, error: NSError) -> Void in
                BOToast(text: "ERROR: during genderize.io request")
        }
    }
    
    
// MARK: - API Requests
    
    /**
    ???
    
    :param: No parameters
    
    :returns: No return value
    */
    func startBecomeParticipantRequest() {
        self.setAllInputsToEnabled(false)
        
        let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL(string: PrivateConstants.backendURL))
        
        let participantParams: NSDictionary = [
            "emergencynumber": self.emergencyNumberTextfield.text!,
            //"hometown": self.hometownTextfield.text!,
            //TODO: Birthday an Backend übertragen
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
        
        // Get user id from CurrentUser
        let userID: Int = CurrentUser.sharedInstance.userid!
        
        requestManager.requestSerializer.setAuthorizationHeaderFieldWithCredential( AFOAuthCredential.retrieveCredentialWithIdentifier("apiCredentials") )
        
        requestManager.PUT(String(format: "user/%i/", userID), parameters: params,
            success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                print("Become Participant Response: ")
                print(response)
                
                CurrentUser.sharedInstance.setAttributesWithJSON(response as! NSDictionary)
                
                // Tracking
                Flurry.logEvent("/user/becomeParticipant/completed_successful")
                
                // Activate Inputs again
                self.setAllInputsToEnabled(true)
                
                self.loadingHUD.hide(true)
                
                self.performSegueWithIdentifier("showJoinTeamViewController", sender: self)
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
    }

}
