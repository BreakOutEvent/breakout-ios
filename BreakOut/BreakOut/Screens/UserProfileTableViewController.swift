//
//  UserProfileViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 28.12.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

import SwiftDate

import StaticDataTableViewController

class UserProfileTableViewController: StaticDataTableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UINavigationBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var participateButtonTableViewCell: UITableViewCell!
    @IBOutlet weak var participateButton: UIButton!
    @IBOutlet weak var firstnameTextfield: UITextField!
    @IBOutlet weak var familynameTextfield: UITextField!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var profilePictureButtonPressed: UIButton!
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var newPasswordTextfield: UITextField!
    
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var birthdayTextfield: UITextField!
    var birthdayDatePicker: UIDatePicker! = UIDatePicker()
    
    
    @IBOutlet var eventInformationTableViewCellCollection: [UITableViewCell]!
    @IBOutlet weak var shirtSizeTextfield: UITextField!
    var shirtSizePicker: UIPickerView! = UIPickerView()
    var shirtSizeDataSourceArray: NSArray = NSArray(objects: "S", "M", "L")
    
    @IBOutlet weak var hometownTextfield: UITextField!
    @IBOutlet weak var phonenumberTextfield: UITextField!
    @IBOutlet weak var emergencyNumberTextfield: UITextField!
    
    var imagePicker: UIImagePickerController = UIImagePickerController()

// MARK: - Screen Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CurrentUser.sharedInstance.downloadUserData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationCurrentUserUpdated", name: Constants.NOTIFICATION_CURRENT_USER_UPDATED, object: nil)
        
        // Style the navigation bar
        self.navigationController!.navigationBar.translucent = false
        self.navigationController!.navigationBar.barTintColor = Style.mainOrange
        self.navigationController!.navigationBar.backgroundColor = Style.mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        self.title = NSLocalizedString("userProfileTitle", comment: "")
        
        // Create save button for navigation item
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveChanges")
        navigationItem.rightBarButtonItem = rightButton
        
        // Create menu buttons for navigation item
        let barButtonImage = UIImage(named: "menu_Icon_white")
        if barButtonImage != nil {
            self.addLeftBarButtonWithImage(barButtonImage!)
        }
        
        // Add the circle mask to the userpicture
        self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 2.0
        self.profilePictureImageView.clipsToBounds = true
        
        // Set the delegates
        self.imagePicker.delegate = self
        
        // Fill the inputs with stored data
        self.fillInputsWithCurrentUserInfo()
        
        // Setup the textfields with different inputtypes instead of keyboard
        self.setupShirtSizePicker()
        self.setupBirthdayDatePicker()
        
        // Add loadingBar to navigationBar        
    }
    
    func notificationCurrentUserUpdated() {
        self.fillInputsWithCurrentUserInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tracking
        Flurry.logEvent("/user/profile", withParameters: nil, timed: true)
        
        // Check UserDefaults for already logged in user
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("userDictionary") == nil {
            self.presentLoginScreen()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/user/profile", withParameters: nil)
    }
    
    func fillInputsWithCurrentUserInfo() {
        self.firstnameTextfield.text = CurrentUser.sharedInstance.firstname
        self.familynameTextfield.text = CurrentUser.sharedInstance.lastname
        
        self.emailTextfield.text = CurrentUser.sharedInstance.email
        
        self.genderSegmentedControl.selectedSegmentIndex = CurrentUser.sharedInstance.genderAsInt()
        //self.birthdayTextfield.text = CurrentUser.sharedInstance.birthday?.toString()
        self.shirtSizeTextfield.text = CurrentUser.sharedInstance.shirtSize
        self.phonenumberTextfield.text = CurrentUser.sharedInstance.phoneNumber
        self.emergencyNumberTextfield.text = CurrentUser.sharedInstance.emergencyNumber
        
        self.profilePictureImageView.image = CurrentUser.sharedInstance.picture
        
        // Check if current user is already participate
        if CurrentUser.sharedInstance.flagParticipant == true {
            self.cell(self.participateButtonTableViewCell, setHidden: true)
            self.cells(self.eventInformationTableViewCellCollection, setHidden: false)
        }else{
            self.cell(self.participateButtonTableViewCell, setHidden: false)
            self.cells(self.eventInformationTableViewCellCollection, setHidden: true)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

    
// MARK: - Image Picker Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let choosenImage: UIImage = image
        
        self.profilePictureImageView.image = choosenImage
        
        CurrentUser.sharedInstance.picture = choosenImage
        CurrentUser.sharedInstance.storeInNSUserDefaults()
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        return
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
// MARK: - Helper Functions
    func presentLoginScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginRegisterViewController: LoginRegisterViewController = storyboard.instantiateViewControllerWithIdentifier("LoginRegisterViewController") as! LoginRegisterViewController
        
        self.presentViewController(loginRegisterViewController, animated: true, completion: nil)
    }
    
    func inputFieldsChanged() -> Bool {
        // TODO: Do we really need such a function?
        return true
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
    
    func setupBirthdayDatePicker() {
        self.birthdayDatePicker.datePickerMode = UIDatePickerMode.Date
        self.birthdayTextfield.inputView = self.birthdayDatePicker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = Style.mainOrange
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "birthdayDatePickerToolbarDoneButtonPressed")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        self.birthdayTextfield.inputAccessoryView = toolBar
    }
    
// MARK: - Picker Toolbar Functions
    func shirtSizePickerToolbarDoneButtonPressed() {
        self.shirtSizeTextfield.text = self.shirtSizeDataSourceArray[self.shirtSizePicker.selectedRowInComponent(0)] as? String
        self.shirtSizeTextfield.resignFirstResponder()
    }
    
    func shirtSizePickerToolbarCancelButtonPressed() {
        self.shirtSizeTextfield.resignFirstResponder()
        
        self.shirtSizeTextfield.text = ""
    }
    
    func birthdayDatePickerToolbarDoneButtonPressed() {
        self.birthdayTextfield.text = self.birthdayDatePicker.date.description
        self.birthdayTextfield.resignFirstResponder()
    }
    
// MARK: - UIPicker DataSource
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
    
// MARK: - Button Actions
    
    func saveChanges() {
        CurrentUser.sharedInstance.firstname = self.firstnameTextfield.text
        CurrentUser.sharedInstance.lastname = self.familynameTextfield.text
        
        CurrentUser.sharedInstance.email = self.emailTextfield.text
        
        CurrentUser.sharedInstance.setGenderFromInt(self.genderSegmentedControl.selectedSegmentIndex)
        CurrentUser.sharedInstance.hometown = self.hometownTextfield.text
        CurrentUser.sharedInstance.phoneNumber = self.phonenumberTextfield.text
        CurrentUser.sharedInstance.emergencyNumber = self.emergencyNumberTextfield.text
        
        CurrentUser.sharedInstance.storeInNSUserDefaults()
        
        BOToast(text: "Stored all Input Values to CurrentUser Object")
    }
    
    @IBAction func profilePictureButtonPressed(sender: UIButton) {
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
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let becomeParticipantTVC: BecomeParticipantTableViewController = storyboard.instantiateViewControllerWithIdentifier("BecomeParticipantTableViewController") as! BecomeParticipantTableViewController
        
        self.presentViewController(becomeParticipantTVC, animated: true, completion: nil)
        /*if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BecomeParticipantTableViewController") {
            self.slideMenuController()?.changeMainViewController(controller, close: true)
        }*/
    }
    
    @IBAction func logoutButtonPressed(sender: UIButton) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nil, forKey: "userDictionary")
        
        self.presentLoginScreen()
    }
}
