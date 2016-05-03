//
//  CreateTeamTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 28.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

import AFOAuth2Manager

import Flurry_iOS_SDK

import MBProgressHUD
import SpinKit

struct BOEvent {
    var id:Int
    var title:String
    var dateUnixTimestamp: Int
    var city:String
    //TODO: add more attributes
}

class CreateTeamTableViewController: UITableViewController, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var addTeampictureButton: UIButton!
    @IBOutlet weak var teampictureImageView: UIImageView!
    @IBOutlet weak var teamNameTextfield: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var eventSelectionTextfield: UITextField!
    @IBOutlet weak var createTeamButton: UIButton!
    
    var eventPicker: UIPickerView! = UIPickerView()
    var eventDataSourceArray: Array<BOEvent> = Array()
    var eventCurrentlySelected: Int?
    
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    var loadingHUD: MBProgressHUD = MBProgressHUD()
    
    override func viewDidLoad() {
        // Add the circle mask to the teampictureImageView
        self.teampictureImageView.layer.cornerRadius = self.teampictureImageView.frame.size.width / 2.0
        self.teampictureImageView.clipsToBounds = true

        self.imagePicker.delegate = self

        // Set color for placeholder text
        self.teamNameTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("teamname", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("email", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.eventSelectionTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("eventselection", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])

        // Set localized Button Texts
        self.createTeamButton.setTitle(NSLocalizedString("createTeamButton", comment: ""), forState: UIControlState.Normal)
        
        self.addTeampictureButton.layer.cornerRadius = self.addTeampictureButton.frame.size.width / 2.0
        
        // Request all Events and setup the EventPicker as Input
        self.eventSelectionTextfield.enabled = false
        self.getAllEventsRequest()
    }
    
    func setupEventPicker() {
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
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        self.eventSelectionTextfield.inputAccessoryView = toolBar
        
        if self.eventDataSourceArray.count > 0 {
            self.eventSelectionTextfield.enabled = true
        }
    }
    
// MARK: - Picker Toolbar Functions
    func eventPickerToolbarDoneButtonPressed() {
        let selectedEvent:BOEvent = self.eventDataSourceArray[self.eventPicker.selectedRowInComponent(0)]
        self.eventSelectionTextfield.text = selectedEvent.title
        self.eventSelectionTextfield.resignFirstResponder()
        self.eventCurrentlySelected = self.eventPicker.selectedRowInComponent(0)
    }
    
// MARK: - UIPicker DataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.eventDataSourceArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let selectedEvent:BOEvent = self.eventDataSourceArray[row]
        return selectedEvent.title
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedEvent:BOEvent = self.eventDataSourceArray[row]
        self.eventSelectionTextfield.text = selectedEvent.title
        self.eventCurrentlySelected = row
    }
    
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
        // Send the create team and send invitation request to the backend
        self.startCreateTeamRequest()
    }
    
// MARK: - Image Picker Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let choosenImage: UIImage = image
        
        self.teampictureImageView.image = choosenImage
        
        self.addTeampictureButton.hidden = true
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        return
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
// MARK: - Helper Functions    
    func setAllInputsToEnabled(enabled: Bool) {
        self.teamNameTextfield.enabled = enabled
        self.emailTextField.enabled = enabled
        self.eventSelectionTextfield.enabled = enabled
    }
    
    func setupLoadingHUD(localizedKey: String) {
        let spinner: RTSpinKitView = RTSpinKitView(style: RTSpinKitViewStyle.Style9CubeGrid, color: UIColor.whiteColor(), spinnerSize: 37.0)
        self.loadingHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.loadingHUD.square = true
        self.loadingHUD.mode = MBProgressHUDMode.CustomView
        self.loadingHUD.customView = spinner
        self.loadingHUD.labelText = NSLocalizedString(localizedKey, comment: "loading")
        spinner.startAnimating()
    }
    
    func presentLoginScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginRegisterViewController: LoginRegisterViewController = storyboard.instantiateViewControllerWithIdentifier("LoginRegisterViewController") as! LoginRegisterViewController
        
        self.presentViewController(loginRegisterViewController, animated: true, completion: nil)
    }
    
    func allInputsAreFilled() -> Bool {
        var allInputsAreFilled = true
        
        if self.teamNameTextfield.text == "" {
            allInputsAreFilled = false
        }
        if self.eventSelectionTextfield.text == "" {
            allInputsAreFilled = false
        }
        if self.emailTextField.text == "" {
            allInputsAreFilled = false
        }
        
        if allInputsAreFilled == false {
            self.setupErrorHUD("Alle Felder müssen ausgefüllt sein!")
            self.loadingHUD.hide(true, afterDelay: 3.0)
            return false
        }
        
        return true
    }
    
    func setupErrorHUD(localizedKey: String) {
        self.loadingHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.loadingHUD.square = false
        self.loadingHUD.mode = MBProgressHUDMode.CustomView
        self.loadingHUD.labelText = NSLocalizedString(localizedKey, comment: "loading")
    }
    
// TODO: Move these to the either The SynchronizationController or the NetworkManager
// MARK: - API Calls
    
    func getAllEventsRequest() {
        
        BOSynchronizeController.sharedInstance.getAllEvents() { (result) in
            self.eventDataSourceArray = result
            self.setupEventPicker()
        }
        
    }
    
    func sendInvitationRequest(teamID: Int) {
        
        if self.emailTextField.text == "" {
            return
        }
        
        self.setAllInputsToEnabled(false)
        
        if let name = teamNameTextfield.text, currentEvent = eventCurrentlySelected {
            let eventID: Int = self.eventDataSourceArray[currentEvent].id
            BOSynchronizeController.sharedInstance.sendInvitationToTeam(teamID, name: name, eventID: eventID) { () in
                self.setAllInputsToEnabled(true)
                
                self.loadingHUD.hide(true)

            }
        }
    }
    
    func startCreateTeamRequest() {
        if !self.allInputsAreFilled() {
            return
        }
        
        // Setup the loading HUD and disable all input fields
        self.setupLoadingHUD("loadingCreateTeam")
        self.loadingHUD.show(true)
        self.setAllInputsToEnabled(false)
        
        if let name = teamNameTextfield.text, currentEvent = eventCurrentlySelected {
            let eventID: Int = self.eventDataSourceArray[currentEvent].id
            BOSynchronizeController.sharedInstance.createTeam(name, eventID: eventID, success: { () in
                self.sendInvitationRequest(2)
                self.setAllInputsToEnabled(true)
                
                self.loadingHUD.hide(true)
            }) { () in
                self.setAllInputsToEnabled(true)
                
                self.loadingHUD.hide(true)
            }
        }
    }
    
}
