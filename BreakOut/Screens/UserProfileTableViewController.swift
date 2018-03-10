//
//  UserProfileViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 28.12.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import UIKit

// Tracking
import Crashlytics


import StaticDataTableViewController

class UserProfileTableViewController: StaticDataTableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UINavigationBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var passwordTableViewCell: UITableViewCell!
    @IBOutlet weak var birthdayTableViewCell: UITableViewCell!
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
        
        CurrentUser.shared.downloadUserData()
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCurrentUserUpdated), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_CURRENT_USER_UPDATED), object: nil)
        
        // Style the navigation bar
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = .mainOrange
        self.navigationController?.navigationBar.backgroundColor = .mainOrange
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.title = "userProfileTitle".local
        
        // Create save button for navigation item
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveChanges))
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
        
        // As long as we don't support the password reset function -> hide the password cell
        self.cell(self.passwordTableViewCell, setHidden: true)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Check UserDefaults for already logged in user
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "userDictionary") == nil {
            self.presentLoginScreen()
        }
    }
    
    func fillInputsWithCurrentUserInfo() {
        self.firstnameTextfield.text = CurrentUser.shared.firstname
        self.familynameTextfield.text = CurrentUser.shared.lastname
        
        self.emailTextfield.text = CurrentUser.shared.email
        
        self.genderSegmentedControl.selectedSegmentIndex = CurrentUser.shared.genderAsInt()
        self.birthdayTextfield.text = CurrentUser.shared.birthday?.toString()
        self.shirtSizeTextfield.text = CurrentUser.shared.shirtSize
        self.hometownTextfield.text = CurrentUser.shared.hometown
        self.phonenumberTextfield.text = CurrentUser.shared.phoneNumber
        self.emergencyNumberTextfield.text = CurrentUser.shared.emergencyNumber
        
        self.profilePictureImageView.image = CurrentUser.shared.picture
        
        // Check if current user is already participate
        if CurrentUser.shared.flagParticipant == true {
            self.cell(self.participateButtonTableViewCell, setHidden: true)
            self.cells(self.eventInformationTableViewCellCollection, setHidden: false)
            self.cell(self.birthdayTableViewCell, setHidden: false)
        } else {
            self.cell(self.participateButtonTableViewCell, setHidden: true) // Always hidden as long as we haven't this function ready
            self.cells(self.eventInformationTableViewCellCollection, setHidden: true)
            self.cell(self.birthdayTableViewCell, setHidden: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    
// MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let choosenImage: UIImage = image
        
        self.profilePictureImageView.image = choosenImage
        
        CurrentUser.shared.picture = choosenImage
        
        self.dismiss(animated: true, completion: nil)
        
        return
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    
    
// MARK: - Helper Functions
    func presentLoginScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginRegisterViewController: LoginRegisterViewController = storyboard.instantiateViewController(withIdentifier: "LoginRegisterViewController") as! LoginRegisterViewController
        
        self.present(loginRegisterViewController, animated: true, completion: nil)
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
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .mainOrange
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserProfileTableViewController.shirtSizePickerToolbarDoneButtonPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserProfileTableViewController.shirtSizePickerToolbarCancelButtonPressed))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.shirtSizeTextfield.inputAccessoryView = toolBar
    }
    
    func setupBirthdayDatePicker() {
        self.birthdayDatePicker.datePickerMode = UIDatePickerMode.date
        self.birthdayTextfield.inputView = self.birthdayDatePicker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .mainOrange
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserProfileTableViewController.birthdayDatePickerToolbarDoneButtonPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.birthdayTextfield.inputAccessoryView = toolBar
    }
    
// MARK: - Picker Toolbar Functions
    func shirtSizePickerToolbarDoneButtonPressed() {
        self.shirtSizeTextfield.text = self.shirtSizeDataSourceArray[self.shirtSizePicker.selectedRow(inComponent: 0)] as? String
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
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.shirtSizeDataSourceArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.shirtSizeDataSourceArray[row] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.shirtSizeTextfield.text = self.shirtSizeDataSourceArray[row] as? String
    }
    
// MARK: - Button Actions
    
    func saveChanges() {
        CurrentUser.shared.firstname = self.firstnameTextfield.text
        CurrentUser.shared.lastname = self.familynameTextfield.text
        
        CurrentUser.shared.email = self.emailTextfield.text
        
        CurrentUser.shared.setGenderFromInt(self.genderSegmentedControl.selectedSegmentIndex)
        CurrentUser.shared.hometown = self.hometownTextfield.text
        CurrentUser.shared.phoneNumber = self.phonenumberTextfield.text
        CurrentUser.shared.emergencyNumber = self.emergencyNumberTextfield.text
        
        CurrentUser.shared.uploadUserData()
        
        //BOToast.log("Stored all Input Values to CurrentUser Object")
    }
    
    @IBAction func profilePictureButtonPressed(_ sender: UIButton) {
        let optionMenu: UIAlertController = UIAlertController(title: nil, message: "sourceOfImage".local, preferredStyle: .actionSheet)
        
        let photoLibraryOption = UIAlertAction(title: "photoLibrary".local, style: .default) { alert in
            print("from library")
            //shows the library
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.modalPresentationStyle = .popover
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cameraOption = UIAlertAction(title: "takeAPhoto".local, style: .default) { alert in
            print("take a photo")
            //shows the camera
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraDevice = .front
            self.imagePicker.modalPresentationStyle = .popover
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }
        let cancelOption = UIAlertAction(title: "cancel".local, style: .cancel) { alert in
            print("Cancel")
            self.dismiss(animated: true, completion: nil)
        }
        
        //Adding the actions to the action sheet. Here, camera will only show up as an option if the camera is available in the first place.
        optionMenu.addAction(photoLibraryOption)
        optionMenu.addAction(cancelOption)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            optionMenu.addAction(cameraOption)
        } else {
            print ("I don't have a camera.")
        }
        
        //Now that the action sheet is set up, we present it.
        self.present(optionMenu, animated: true, completion: nil)
    }
    
//    @IBAction func participateButtonPressed(_ sender: UIButton) {
//        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let becomeParticipantTVC: BecomeParticipantTableViewController = storyboard.instantiateViewController(withIdentifier: "BecomeParticipantTableViewController") as! BecomeParticipantTableViewController
//        
//        self.present(becomeParticipantTVC, animated: true, completion: nil)
//        /*if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BecomeParticipantTableViewController") {
//            self.slideMenuController()?.changeMainViewController(controller, close: true)
//        }*/
//    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        CurrentUser.resetUser()
        
        CurrentUser.resetUser()
        BreakOut.shared.logout()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_PRESENT_WELCOME_SCREEN), object: nil)
    }
}
