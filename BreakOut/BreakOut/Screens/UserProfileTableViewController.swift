//
//  UserProfileViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 28.12.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

class UserProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var participateButton: UIButton!
    @IBOutlet weak var firstnameTextfield: UITextField!
    @IBOutlet weak var familynameTextfield: UITextField!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var profilePictureButtonPressed: UIButton!
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var newPasswordTextfield: UITextField!
    
    var imagePicker: UIImagePickerController = UIImagePickerController()

// MARK: - Screen Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add the circle mask to the userpicture
        self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 2.0
        self.profilePictureImageView.clipsToBounds = true
        
        self.imagePicker.delegate = self
        
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
    }
    

    
// MARK: - Image Picker Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let choosenImage: UIImage = image
        
        self.profilePictureImageView.image = choosenImage
        
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
    
// MARK: - Button Actions
    
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
    }
    
    @IBAction func logoutButtonPressed(sender: UIButton) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nil, forKey: "userDictionary")
        
        self.presentLoginScreen()
    }
}
