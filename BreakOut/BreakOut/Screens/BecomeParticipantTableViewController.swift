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

class BecomeParticipantTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var addUserpictureButton: UIButton!
    @IBOutlet weak var userpictureImageView: UIImageView!
    @IBOutlet weak var firstNameTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var shirtSizeTextfield: UITextField!
    @IBOutlet weak var hometownTextfield: UITextField!
    @IBOutlet weak var phonenumberTextfield: UITextField!
    @IBOutlet weak var emergencyNumberTextfield: UITextField!
    @IBOutlet weak var participateButton: UIButton!
    
    var loadingHUD: MBProgressHUD = MBProgressHUD()
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
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
        self.hometownTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("hometown", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.phonenumberTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("phonenumber", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.emergencyNumberTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("emergencyNumber", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        
        // Set localized Button Texts
        self.participateButton.setTitle(NSLocalizedString("participateButton", comment: ""), forState: UIControlState.Normal)
        
        self.addUserpictureButton.layer.cornerRadius = self.addUserpictureButton.frame.size.width / 2.0
        
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
    }
    
// MARK: - TextField Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.firstNameTextfield {
            // Switch focus to other text field
            self.lastNameTextfield.becomeFirstResponder()
        }else if textField == self.lastNameTextfield{
            self.emailTextField.becomeFirstResponder()
        }else if textField == self.emailTextField{
            self.shirtSizeTextfield.becomeFirstResponder()
        }else if textField == self.shirtSizeTextfield{
            self.hometownTextfield.becomeFirstResponder()
        }else if textField == self.hometownTextfield{
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
        // Send the participation request to the backend
        self.setupLoadingHUD("loadingParticipant")
        self.loadingHUD.show(true)
        self.startBecomeParticipantRequest()
    }
    
// MARK: - Image Picker Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let choosenImage: UIImage = image
        
        self.userpictureImageView.image = choosenImage
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        return
        
        /*let cropPictureController = LECropPictureViewController.init(image: choosenImage, andCropPictureType: LECropPictureType.Rounded)
        cropPictureController.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        cropPictureController.borderWidth = 1.0
        cropPictureController.acceptButtonItem?.tintColor = Style.mainOrange
        cropPictureController.acceptButtonItem?.title = NSLocalizedString("accept", comment: "")
        cropPictureController.cancelButtonItem?.tintColor = Style.mainOrange
        cropPictureController.cancelButtonItem?.title = NSLocalizedString("cancel", comment: "")
        
        cropPictureController.photoAcceptedBlock = {(croppedImage: UIImage!) in
            self.userpictureImageView.image = croppedImage
        }
        
        self.presentViewController(cropPictureController, animated: false, completion: nil)*/
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
    
    func setAllInputsToEnabled(enabled: Bool) {
        self.firstNameTextfield.enabled = enabled
        self.lastNameTextfield.enabled = enabled
        self.emailTextField.enabled = enabled
        self.genderSegmentedControl.enabled = enabled
        self.shirtSizeTextfield.enabled = enabled
        self.hometownTextfield.enabled = enabled
        self.phonenumberTextfield.enabled = enabled
        self.emergencyNumberTextfield.enabled = enabled
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
                
                self.performSegueWithIdentifier("showJoinTeamTableViewController", sender: self)
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
