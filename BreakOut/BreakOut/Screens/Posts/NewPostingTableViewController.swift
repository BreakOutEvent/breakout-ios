//
//  NewPostingTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 16.04.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import CoreLocation

// Database
import MagicalRecord

// Tracking
import Flurry_iOS_SDK
import Crashlytics

import MBProgressHUD

class NewPostingTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var postingPictureImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    let locationManager = CLLocationManager()
    var newLongitude: Double = 0.0
    var newLatitude: Double = 0.0
    
    var loadingHUD: MBProgressHUD = MBProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style the navigation bar
        self.navigationController!.navigationBar.translucent = false
        self.navigationController!.navigationBar.barTintColor = Style.mainOrange
        self.navigationController!.navigationBar.backgroundColor = Style.mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        self.title = NSLocalizedString("newPostingTitle", comment: "")
        
        // Create posting button for navigation item
        let rightButton = UIBarButtonItem(image: UIImage(named: "post_Icon"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(sendPostingButtonPressed))
        navigationItem.rightBarButtonItem = rightButton
        
        // Create menu buttons for navigation item
        let barButtonImage = UIImage(named: "menu_Icon_white")
        if barButtonImage != nil {
            self.addLeftBarButtonWithImage(barButtonImage!)
        }

        self.imagePicker.delegate = self
        
        self.messageTextView.text = NSLocalizedString("newPostingEmptyMessage", comment: "Empty")
        self.styleMessageInput(true)
        
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tracking
        Flurry.logEvent("/newPostingTableViewController", timed: true)
        Answers.logCustomEventWithName("/newPostingTableViewController", customAttributes: [:])
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/newPostingTableViewController", withParameters: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resetAllInputs() {
        self.postingPictureImageView.image = UIImage()
        
        self.messageTextView.resignFirstResponder()
        self.messageTextView.text = NSLocalizedString("newPostingEmptyMessage", comment: "Empty")
        self.styleMessageInput(true)
    }
    
    func setupLoadingHUD(localizedKey: String) {
        self.loadingHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.loadingHUD.square = true
        self.loadingHUD.mode = MBProgressHUDMode.CustomView
        
        //TODO: Add Done image
        
        self.loadingHUD.labelText = NSLocalizedString(localizedKey, comment: "loading")
    }
    
    func styleMessageInput(placeholder: Bool) {
        if placeholder {
            self.messageTextView.textColor = UIColor.lightGrayColor()
        }else{
            self.messageTextView.textColor = UIColor.blackColor()
        }
    }

    
// MARK: - UITextViewDelegate
    func textViewDidChange(textView: UITextView) {
        if textView.text == NSLocalizedString("newPostingEmptyMessage", comment: "Empty") {
            self.styleMessageInput(true)
        }else{
            self.styleMessageInput(false)
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == NSLocalizedString("newPostingEmptyMessage", comment: "Empty") {
            textView.text = ""
        }
    }
    
    
    
// MARK: - Button Actions
    
    func sendPostingButtonPressed() {
        let newPosting: BOPost = BOPost.MR_createEntity()! as BOPost
        
        newPosting.flagNeedsUpload = true
        newPosting.text = self.messageTextView.text
        newPosting.latitude = self.newLatitude
        newPosting.longitude = self.newLongitude
        newPosting.date = NSDate()
        
        newPosting.city = self.locationLabel.text

        var withImage:Bool = false
        if let image = postingPictureImageView.image {
            // User selected Image for this post
            let newImage:BOImage = BOImage.createWithImage(image)
        
            newPosting.images.insert(newImage)
            
            withImage = true
        }
        
        // Save
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        
        if BOSynchronizeController.sharedInstance.internetReachabilityStatus() == "wifi" {
            newPosting.upload()
        }
        
        // After Saving throw User message and reset inputs
        self.setupLoadingHUD("New Posting saved!")
        self.loadingHUD.hide(true, afterDelay: 3.0)
        self.resetAllInputs()
        
        // Tracking
        Flurry.logEvent("/newPostingTVC/posting_stored", withParameters: ["withImage":withImage])
        Answers.logCustomEventWithName("/newPostingTVC/posting_stored", customAttributes: ["withImage":withImage])
    }
    
    @IBAction func addAttachementButtonPressed(sender: UIButton) {
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
    
// MARK: - Location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        if manager.location?.verticalAccuracy < 50 && manager.location?.horizontalAccuracy < 50.0 {
            
            // Start Reverse Geocoding to retrieve the cityname
            self.retrieveCurrentCityName(manager.location!)
            
            // Stop further location updates as accuracy is enough
            manager.stopUpdatingLocation()
            
            // Store the coordinates
            self.newLongitude = (manager.location?.coordinate.longitude)!
            self.newLatitude = (manager.location?.coordinate.latitude)!
        }
    }
    
    func retrieveCurrentCityName(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil) {
                    BOToast.log("reverse geodcode fail: \(error!.localizedDescription)", level: BOToast.Level.Error )
                }
                
                let pm = placemarks! as [CLPlacemark]
                if pm.count > 0 {
                    let placeMark: CLPlacemark = placemarks![0] as CLPlacemark
                    BOToast.log("Retrieved City: \(placeMark.locality)", level: BOToast.Level.Success)
                    self.locationLabel.text = placeMark.locality
                }
        })
    }
    
// MARK: - Image Picker Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let choosenImage: UIImage = image
        
        self.postingPictureImageView.image = choosenImage
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        return
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
