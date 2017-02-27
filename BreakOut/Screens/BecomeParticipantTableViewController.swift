//
//  BecomeParticipantTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 10.01.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Sweeft
import Flurry_iOS_SDK

import MBProgressHUD
import SpinKit

import LECropPictureViewController

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
        backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
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
        self.participateButton.setTitle(NSLocalizedString("participateButton", comment: ""), for: UIControlState())
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        // Tracking
        Flurry.logEvent("/user/becomeParticipant", withParameters: nil, timed: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/user/becomeParticipant", withParameters: nil)
    }
    
// MARK: - Initial Input setup 
    
    func fillInputsWithCurrentUserInfo() {
        self.firstNameTextfield.text = CurrentUser.shared.firstname
        self.lastNameTextfield.text = CurrentUser.shared.lastname
        self.emailTextField.text = CurrentUser.shared.email
        self.genderSegmentedControl.selectedSegmentIndex = CurrentUser.shared.genderAsInt()
        
        self.shirtSizeTextfield.text = CurrentUser.shared.shirtSize
        self.emergencyNumberTextfield.text = CurrentUser.shared.emergencyNumber
        self.phonenumberTextfield.text = CurrentUser.shared.phoneNumber
    }
    
// MARK: - Picker Setup & Button functions
    
    // MARK: Birthday Picker
    
    func setupBirthdayDatePicker() {
        self.birthdayDatePicker.datePickerMode = UIDatePickerMode.date
        self.birthdayTextField.inputView = self.birthdayDatePicker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Style.mainOrange
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BecomeParticipantTableViewController.birthdayDatePickerToolbarDoneButtonPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.birthdayTextField.inputAccessoryView = toolBar
    }
    
    func birthdayDatePickerToolbarDoneButtonPressed() {
        self.birthdayTextField.text = self.birthdayDatePicker.date.description
        self.birthdayTextField.resignFirstResponder()
    }
    
    // MARK: T-Shirt size Picker
    
    func addSimpleDoneToolbarToTextField(_ textfield: UITextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Style.mainOrange
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BecomeParticipantTableViewController.textFieldToolbarDoneButtonPressed(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textfield.inputAccessoryView = toolBar
    }
    
    func textFieldToolbarDoneButtonPressed(_ sender: UIBarButtonItem) {
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
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Style.mainOrange
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BecomeParticipantTableViewController.shirtSizePickerToolbarDoneButtonPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: "shirtSizePickerToolbarCancelButtonPressed")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.shirtSizeTextfield.inputAccessoryView = toolBar
    }
    
    func shirtSizePickerToolbarDoneButtonPressed() {
        self.shirtSizeTextfield.text = self.shirtSizeDataSourceArray[self.shirtSizePicker.selectedRow(inComponent: 0)] as? String
        self.shirtSizeTextfield.resignFirstResponder()
    }
    
    // MARK: T-Shirt size Picker DataSource
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
    
// MARK: - TextField Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.currentTextFieldWithFirstResponder = textField
    }
    
// MARK: - Button functions
    
    @IBAction func addUserpictureButtonPressed(_ sender: UIButton) {
        
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
    
    @IBAction func participateButtonPressed(_ sender: UIButton) {
        if self.allInputsAreFilled() {
            // Send the participation request to the backend
            self.setupLoadingHUD("loadingParticipant")
            self.loadingHUD.show(true)
            self.startBecomeParticipantRequest()
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
// MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let choosenImage: UIImage = image
        
        self.userpictureImageView.image = choosenImage
        
        self.addUserpictureButton.isHidden = true
        
        self.dismiss(animated: true, completion: nil)
        
        return
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
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
    
    func setupErrorHUD(_ localizedKey: String) {
        self.loadingHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loadingHUD.isSquare = false
        self.loadingHUD.mode = MBProgressHUDMode.customView
        self.loadingHUD.labelText = NSLocalizedString(localizedKey, comment: "loading")
    }
    
    func setAllInputsToEnabled(_ enabled: Bool) {
        self.firstNameTextfield.isEnabled = enabled
        self.lastNameTextfield.isEnabled = enabled
        self.emailTextField.isEnabled = enabled
        self.genderSegmentedControl.isEnabled = enabled
        self.shirtSizeTextfield.isEnabled = enabled
        self.birthdayTextField.isEnabled = enabled
        self.phonenumberTextfield.isEnabled = enabled
        self.emergencyNumberTextfield.isEnabled = enabled
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
        Gender.gender(for: self.firstNameTextfield.text.?).onSuccess { gender in
            self.genderSegmentedControl.selectedSegmentIndex = gender.hashValue
        }
    }
    
    func presentLoginScreenFromViewController() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginRegisterViewController: LoginRegisterViewController = storyboard.instantiateViewController(withIdentifier: "LoginRegisterViewController") as! LoginRegisterViewController
        
        self.present(loginRegisterViewController, animated: true, completion: nil)
    }
    
    
// MARK: - API Requests
    
    /**
    ???
    
    :param: No parameters
    
    :returns: No return value
    */
    func startBecomeParticipantRequest() {
        
        self.setAllInputsToEnabled(false)
        
        let genderAsString = CurrentUser.shared.stringGenderFromInt(self.genderSegmentedControl.selectedSegmentIndex)

        if let emergency = emergencyNumberTextfield.text, let phone = phonenumberTextfield.text, let shirt = shirtSizeTextfield.text, let first = firstNameTextfield.text, let last = lastNameTextfield.text, let email = emailTextField.text {
            
            Participant.become(firstName: first, lastName: last, gender: genderAsString,
                               email: email, emergencyNumber: emergency,
                               phone: phone, shirtSize: shirt).onSuccess { _ in
                    
                    self.setAllInputsToEnabled(true)
                    self.loadingHUD.hide(true)
                    self.performSegue(withIdentifier: "showJoinTeamViewController", sender: self)
                }
                .onError { _ in
                    // Activate Inputs again
                    self.setAllInputsToEnabled(true)
                    
                    self.loadingHUD.hide(true)
                }
        }
        
    }

}
