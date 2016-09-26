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
    
    
    var chosenImage: UIImage?
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
        self.createTeamButton.setTitle(NSLocalizedString("createTeamButton", comment: ""), for: UIControlState())
        
        self.addTeampictureButton.layer.cornerRadius = self.addTeampictureButton.frame.size.width / 2.0
        
        // Request all Events and setup the EventPicker as Input
        self.eventSelectionTextfield.isEnabled = false
        self.getAllEventsRequest()
    }
    
    func setupEventPicker() {
        // Set the Delegates for the EventPicker and connect Picker & Toolbar with the TextField
        self.eventPicker.delegate = self
        self.eventPicker.dataSource = self
        self.eventSelectionTextfield.inputView = self.eventPicker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Style.mainOrange
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CreateTeamTableViewController.eventPickerToolbarDoneButtonPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.eventSelectionTextfield.inputAccessoryView = toolBar
        
        if self.eventDataSourceArray.count > 0 {
            self.eventSelectionTextfield.isEnabled = true
        }
    }
    
// MARK: - Picker Toolbar Functions
    func eventPickerToolbarDoneButtonPressed() {
        let selectedEvent:BOEvent = self.eventDataSourceArray[self.eventPicker.selectedRow(inComponent: 0)]
        self.eventSelectionTextfield.text = selectedEvent.title
        self.eventSelectionTextfield.resignFirstResponder()
        self.eventCurrentlySelected = self.eventPicker.selectedRow(inComponent: 0)
    }
    
// MARK: - UIPicker DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.eventDataSourceArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let selectedEvent:BOEvent = self.eventDataSourceArray[row]
        return selectedEvent.title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedEvent:BOEvent = self.eventDataSourceArray[row]
        self.eventSelectionTextfield.text = selectedEvent.title
        self.eventCurrentlySelected = row
    }
    
// MARK: - TextField Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    @IBAction func addTeampictureButtonPressed(_ sender: UIButton) {
        
        let optionMenu: UIAlertController = UIAlertController(title: nil, message: NSLocalizedString("sourceOfImage", comment: ""), preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let photoLibraryOption = UIAlertAction(title: NSLocalizedString("photoLibrary", comment: ""), style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) -> Void in
            print("from library")
            //shows the library
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.modalPresentationStyle = .popover
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let cameraOption = UIAlertAction(title: NSLocalizedString("takeAPhoto", comment: ""), style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) -> Void in
            print("take a photo")
            //shows the camera
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraDevice = .front
            self.imagePicker.modalPresentationStyle = .popover
            self.present(self.imagePicker, animated: true, completion: nil)
            
        })
        let cancelOption = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancel")
            self.dismiss(animated: true, completion: nil)
        })
        
        //Adding the actions to the action sheet. Here, camera will only show up as an option if the camera is available in the first place.
        optionMenu.addAction(photoLibraryOption)
        optionMenu.addAction(cancelOption)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
            print ("I don't have a camera.")
        }
        
        //Now that the action sheet is set up, we present it.
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func createTeamButtonPressed(_ sender: UIButton) {
        // Send the create team and send invitation request to the backend
        self.startCreateTeamRequest()
    }
    
// MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let choosenImage: UIImage = image
        
        self.teampictureImageView.image = choosenImage
        
        self.chosenImage = choosenImage
        
        self.addTeampictureButton.isHidden = true
        
        self.dismiss(animated: true, completion: nil)
        
        return
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
// MARK: - Helper Functions    
    func setAllInputsToEnabled(_ enabled: Bool) {
        self.teamNameTextfield.isEnabled = enabled
        self.emailTextField.isEnabled = enabled
        self.eventSelectionTextfield.isEnabled = enabled
    }
    
    func setupLoadingHUD(_ localizedKey: String) {
        let spinner: RTSpinKitView = RTSpinKitView(style: RTSpinKitViewStyle.style9CubeGrid, color: UIColor.white, spinnerSize: 37.0)
        self.loadingHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loadingHUD.isSquare = true
        self.loadingHUD.mode = MBProgressHUDMode.customView
        self.loadingHUD.customView = spinner
        self.loadingHUD.labelText = NSLocalizedString(localizedKey, comment: "loading")
        spinner.startAnimating()
    }
    
    func presentLoginScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginRegisterViewController: LoginRegisterViewController = storyboard.instantiateViewController(withIdentifier: "LoginRegisterViewController") as! LoginRegisterViewController
        
        self.present(loginRegisterViewController, animated: true, completion: nil)
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
    
    func setupErrorHUD(_ localizedKey: String) {
        self.loadingHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loadingHUD.isSquare = false
        self.loadingHUD.mode = MBProgressHUDMode.customView
        self.loadingHUD.labelText = NSLocalizedString(localizedKey, comment: "loading")
    }
    
// TODO: Move these to the either The SynchronizationController or the NetworkManager
// MARK: - API Calls
    
    func getAllEventsRequest() {
        
        BOSynchronizeController.teams.getAllEvents() { (result) in
            self.eventDataSourceArray = result
            self.setupEventPicker()
        }
        
    }
    
    func sendInvitationRequest(_ teamID: Int) {
        
        if self.emailTextField.text == "" {
            return
        }
        
        self.setAllInputsToEnabled(false)
        
        if let name = teamNameTextfield.text, let currentEvent = eventCurrentlySelected {
            let eventID: Int = self.eventDataSourceArray[currentEvent].id
            BOSynchronizeController.teams.sendInvitationToTeam(teamID, name: name, eventID: eventID) { () in
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
        
        if let name = teamNameTextfield.text, let currentEvent = eventCurrentlySelected {
            let eventID: Int = self.eventDataSourceArray[currentEvent].id
            BOSynchronizeController.teams.createTeam(name, eventID: eventID, image: chosenImage, success: { () in
                self.sendInvitationRequest(2)
                self.setAllInputsToEnabled(true)
                self.loadingHUD.hide(true)
                self.dismiss(animated: true, completion: nil)
            }) { () in
                self.setAllInputsToEnabled(true)
                
                self.loadingHUD.hide(true)
            }
        }
    }
    
}
