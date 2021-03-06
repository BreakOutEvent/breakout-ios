//
//  NewPostingTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 16.04.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import CoreLocation

import Sweeft

// Tracking
import Flurry_iOS_SDK
import Crashlytics

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
    
    @IBOutlet weak var mediaCell: UITableViewCell!
    @IBOutlet weak var challengeCell: UITableViewCell!
    @IBOutlet weak var challengeImageView: UIButton!
    @IBOutlet weak var postingPictureImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    var media: NewMedia? {
        didSet {
            postingPictureImageView.image = media?.previewImage
        }
    }
    
    let locationManager = CLLocationManager()
    var newLongitude: Double = 0.0
    var newLatitude: Double = 0.0
    var newCity: String?
    
    var rightButton: UIBarButtonItem!
    
    var isShowingMenu = true
    
    @IBOutlet weak var challengeLabel: UILabel!
    var newChallenge: Challenge?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelNormal
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        // Style the navigation bar
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = .mainOrange
        self.navigationController!.navigationBar.backgroundColor = .mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.title = "newPostingTitle".local
        
        // Create posting button for navigation item
        rightButton = UIBarButtonItem(image: UIImage(named: "checkmark_Icon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(sendPostingButtonPressed))
        navigationItem.rightBarButtonItem = rightButton
        
        let cancelButton = UIBarButtonItem(image: UIImage(named: "cancel_Icon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(closeView))
        navigationItem.leftBarButtonItem = cancelButton
        
        // Create menu buttons for navigation item
        /*let barButtonImage = UIImage(named: "menu_Icon_white")
        if barButtonImage != nil {
            self.addLeftBarButtonWithImage(barButtonImage!)
        }*/
        

        self.imagePicker.delegate = self
        
        self.messageTextView.text = "newPostingEmptyMessage".localized(with: "Empty")
        self.challengeLabel.text = "newPostingEmptyChallenge".localized(with: "Empty")
        self.styleMessageInput(true)
        
        self.locationLabel.text = "retrievingCurrentLocation".localized(with: "Empty Location")
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isShowingMenu && navigationController?.isBeingDismissed ?? false {
            UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelStatusBar + 1
        }
    }
    
    /*func closeView() {
        self.closeView(false)
    }*/
    
    func closeView(_ showAllPostingsList: Bool = false) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        
        if showAllPostingsList {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_NEW_POSTING_CLOSED_WANTS_LIST), object: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let text = newChallenge?.text {
            self.challengeLabel.text = text
            self.challengeImageView.setImage(#imageLiteral(resourceName: "team-challanges_Icon"), for: .normal)
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
        self.messageTextView.text = "newPostingEmptyMessage".localized(with: "Empty")
        self.styleMessageInput(true)
    }
    
    func styleMessageInput(_ placeholder: Bool) {
        rightButton.isEnabled = !placeholder
        if placeholder {
            self.messageTextView.textColor = .lightGray
        } else {
            self.messageTextView.textColor = .black
        }
    }
    
    func styleChallengeLabel() {
        if self.challengeLabel.text == "newPostingEmptyChallenge".localized(with: "Empty") {
            self.challengeLabel.textColor = .lightGray
        } else {
            self.challengeLabel.textColor = .black
        }
    }

    
// MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "newPostingEmptyMessage".localized(with: "Empty") || textView.text == "" {
            self.styleMessageInput(true)
        } else {
            self.styleMessageInput(false)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "newPostingEmptyMessage".localized(with: "Empty") {
            textView.text = ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return mediaCell.frame.height
        }
        if indexPath.row == 1 {
            return challengeCell.frame.height
        }
        return tableView.frame.height - mediaCell.frame.height - challengeCell.frame.height
    }
    
    
    
// MARK: - Button Actions
    
    func sendPostingButtonPressed() {
        let media = ![self.media]
        
        let activity = BOActivityOverlayController.create()
        activity?.modalTransitionStyle = .crossDissolve
        self.present(activity!, animated: true) {
            Post.post(text: self.messageTextView.text,
                      latitude: self.newLatitude,
                      longitude: self.newLongitude,
                      city: self.newCity,
                      challenge: self.newChallenge,
                      media: media)
            .onSuccess { post in
                
                activity?.success {
                    self.resetAllInputs()
                    
                    self.isShowingMenu = false
                    
                    let withImage = !media.isEmpty
                    
                    // Tracking
                    Flurry.logEvent("/newPostingTVC/posting_stored", withParameters: ["withImage": withImage])
                    Answers.logCustomEvent(withName: "/newPostingTVC/posting_stored", customAttributes: ["withImage": withImage.description])
                    
                    let defaults = UserDefaults.standard
                    defaults.set(Date(), forKey: "lastPostingSent")
                    defaults.synchronize()
                    BOPushManager.shared.setupAllLocalPushNotifications()
                    self.closeView(true)
                    
                }
                
            }
            .onError { _ in
                activity?.error()
            }
        }
        
        // After Saving throw User message and reset inputs
        
    }
    
    @IBAction func addAttachementButtonPressed(_ sender: UIButton) {
        let optionMenu: UIAlertController = UIAlertController(title: nil, message: "sourceOfImage".local, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let photoLibraryOption = UIAlertAction(title: "photoLibrary".local, style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) -> Void in
            print("from library")
            //shows the library
            self.imagePicker.present(over: self, with: .photoLibrary)
        })
        let cameraOption = UIAlertAction(title: "takeAPhoto".local, style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) -> Void in
            print("take a photo")
            //shows the camera
            self.imagePicker.present(over: self, with: .camera)
            
        })
        let cancelOption = UIAlertAction(title: "cancel".local, style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancel")
            self.dismiss(animated: true, completion: nil)
        })
        
        //Adding the actions to the action sheet. Here, camera will only show up as an option if the camera is available in the first place.
        optionMenu.addAction(photoLibraryOption)
        optionMenu.addAction(cancelOption)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true {
            optionMenu.addAction(cameraOption)
        } else {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.media = NewMedia(from: info)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
        if indexPath.row == 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
            let challengesTableViewController: ChallengesTableViewController = storyboard.instantiateViewController(withIdentifier: "ChallengesTableViewController") as! ChallengesTableViewController
            challengesTableViewController.parentNewPostingTVC = self
            self.navigationController?.pushViewController(challengesTableViewController, animated: true)
        }
    }
    
    

}
