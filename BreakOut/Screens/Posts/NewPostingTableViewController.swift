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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class NewPostingTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var postingPictureImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    let locationManager = CLLocationManager()
    var newLongitude: Double = 0.0
    var newLatitude: Double = 0.0
    var newCity: String?
    
    @IBOutlet weak var challengeLabel: UILabel!
    var newChallenge:BOChallenge?
    
    var loadingHUD: MBProgressHUD = MBProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style the navigation bar
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = Style.mainOrange
        self.navigationController!.navigationBar.backgroundColor = Style.mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.title = NSLocalizedString("newPostingTitle", comment: "")
        
        // Create posting button for navigation item
        let rightButton = UIBarButtonItem(image: UIImage(named: "checkmark_Icon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(sendPostingButtonPressed))
        navigationItem.rightBarButtonItem = rightButton
        
        let cancelButton = UIBarButtonItem(image: UIImage(named: "cancel_Icon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(closeView))
        navigationItem.leftBarButtonItem = cancelButton
        
        // Create menu buttons for navigation item
        /*let barButtonImage = UIImage(named: "menu_Icon_white")
        if barButtonImage != nil {
            self.addLeftBarButtonWithImage(barButtonImage!)
        }*/
        

        self.imagePicker.delegate = self
        
        self.messageTextView.text = NSLocalizedString("newPostingEmptyMessage", comment: "Empty")
        self.challengeLabel.text = NSLocalizedString("newPostingEmptyChallenge", comment: "Empty")
        self.styleMessageInput(true)
        
        self.locationLabel.text = NSLocalizedString("retrievingCurrentLocation", comment: "Empty Location")
        
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
    
    /*func closeView() {
        self.closeView(false)
    }*/
    
    func closeView(_ showAllPostingsList:Bool = false) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        
        if showAllPostingsList {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_NEW_POSTING_CLOSED_WANTS_LIST), object: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if newChallenge != nil {
            self.challengeLabel.text = String(format: "%0.2f € -- %@", (newChallenge?.amount?.doubleValue)!, (newChallenge?.text)!)
            self.styleChallengeLabel()
        }
        // Tracking
        Flurry.logEvent("/newPostingTableViewController", timed: true)
        Answers.logCustomEvent(withName: "/newPostingTableViewController", customAttributes: [:])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
    
    func setupLoadingHUD(_ localizedKey: String) {
        self.loadingHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loadingHUD.isSquare = true
        self.loadingHUD.mode = MBProgressHUDMode.customView
        
        //TODO: Add Done image
        
        self.loadingHUD.labelText = NSLocalizedString(localizedKey, comment: "loading")
    }
    
    func styleMessageInput(_ placeholder: Bool) {
        if placeholder {
            self.messageTextView.textColor = UIColor.lightGray
        }else{
            self.messageTextView.textColor = UIColor.black
        }
    }
    
    func styleChallengeLabel() {
        if self.challengeLabel.text == NSLocalizedString("newPostingEmptyChallenge", comment: "Empty") {
            self.challengeLabel.textColor = UIColor.lightGray
        }else{
            self.challengeLabel.textColor = UIColor.black
        }
    }

    
// MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == NSLocalizedString("newPostingEmptyMessage", comment: "Empty") {
            self.styleMessageInput(true)
        }else{
            self.styleMessageInput(false)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == NSLocalizedString("newPostingEmptyMessage", comment: "Empty") {
            textView.text = ""
        }
    }
    
    
    
// MARK: - Button Actions
    
    func sendPostingButtonPressed() {
        let newPosting: BOPost = BOPost.mr_createEntity()! as BOPost
        
        newPosting.flagNeedsUpload = true
        newPosting.flagNeedsDownload = false
        newPosting.text = self.messageTextView.text
        newPosting.latitude = NSNumber(value: self.newLatitude)
        newPosting.longitude = NSNumber(value: self.newLongitude)
        newPosting.date = Date()
        
        if self.newCity == nil {
            newPosting.city = nil
        }else{
            newPosting.city = self.newCity
        }
        

        var withImage:Bool = false
        if let image = postingPictureImageView.image {
            // User selected Image for this post
            let newImage:BOImage = BOImage.createWithImage(image)
            newImage.flagNeedsUpload = true
        
            newPosting.images.insert(newImage)
            
            withImage = true
        }
        
        // Check wether a challenge is connected to the posting
        if self.newChallenge != nil {
            newPosting.challenge = self.newChallenge
        }
        
        // Save
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
        BOSynchronizeController.sharedInstance.triggerUpload()
        
        // After Saving throw User message and reset inputs
        self.setupLoadingHUD("New Posting saved!")
        self.loadingHUD.hide(true, afterDelay: 3.0)
        self.resetAllInputs()
        
        // Tracking
        Flurry.logEvent("/newPostingTVC/posting_stored", withParameters: ["withImage":withImage])
        Answers.logCustomEvent(withName: "/newPostingTVC/posting_stored", customAttributes: ["withImage":withImage.description])
        
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: "lastPostingSent")
        defaults.synchronize()
        BOPushManager.sharedInstance.setupAllLocalPushNotifications()
        
        self.closeView(true)
    }
    
    @IBAction func addAttachementButtonPressed(_ sender: UIButton) {
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
    
    var reverseGeocoderRunning: Bool = false
    
// MARK: - Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        // Store the coordinates
        self.newLongitude = (manager.location?.coordinate.longitude)!
        self.newLatitude = (manager.location?.coordinate.latitude)!
        
        if self.newCity == nil {
            self.locationLabel.text = String(format: "lat: %3.3f long: %3.3f", self.newLatitude, self.newLongitude)
        }
        
        if manager.location?.verticalAccuracy < 150 && manager.location?.horizontalAccuracy < 150.0 && self.newCity == nil && reverseGeocoderRunning == false {
            
            // Start Reverse Geocoding to retrieve the cityname
            self.retrieveCurrentCityName(manager.location!)
            
            // Stop further location updates as accuracy is enough
            //manager.stopUpdatingLocation()
            
        }
    }
    
    func retrieveCurrentCityName(_ location: CLLocation) {
        self.reverseGeocoderRunning = true
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                self.reverseGeocoderRunning = false
                if (error != nil) {
                    //BOToast.log("reverse geodcode fail: \(error!.localizedDescription)", level: BOToast.Level.Error )
                }else{
                
                    let pm = placemarks! as [CLPlacemark]
                    if pm.count > 0 {
                        let placeMark: CLPlacemark = placemarks![0] as CLPlacemark
                        //BOToast.log("Retrieved City: \(placeMark.locality)", level: BOToast.Level.Success)
                        self.locationLabel.text = placeMark.locality
                        self.newCity = placeMark.locality
                    }
                }
        })
    }
    
// MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let choosenImage: UIImage = image
        
        self.postingPictureImageView.image = choosenImage
        
        self.dismiss(animated: true, completion: nil)
        
        return
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 1 {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
            let challengesTableViewController: ChallengesTableViewController = storyboard.instantiateViewController(withIdentifier: "ChallengesTableViewController") as! ChallengesTableViewController
            challengesTableViewController.parentNewPostingTVC = self
            self.navigationController?.pushViewController(challengesTableViewController, animated: true)
        }
    }

}
