//
//  BOLocationManager.swift
//  BreakOut
//
//  Created by Leo Käßner on 25.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import CoreLocation

// Database
import MagicalRecord

// Tracking
import Flurry_iOS_SDK
import Crashlytics

class BOLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = BOLocationManager()
    
    var lastKnownLocation: CLLocation?
    
    let locationManager = CLLocationManager()
    
    func start() {
        // set delegate
        locationManager.delegate = self
        
        // aks user for permission
        let status = CLLocationManager.authorizationStatus()
        if status == .Denied || status == .NotDetermined || status == .AuthorizedWhenInUse || status == .Restricted{
            locationManager.requestAlwaysAuthorization()
        }
        
        // set accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        // set distance filter in meters
        locationManager.distanceFilter = 1000
        
        // allow background updates
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            print("iOS Version not capable of background location updates!")
        }
        
        // set properties for battery life time enhencement
        locationManager.pausesLocationUpdatesAutomatically = true
        
        // start monitoring
        if CLLocationManager.locationServicesEnabled(){
            print("location Services are enabled. Start Updating Locations ...")
            locationManager.startUpdatingLocation()
        }
    }
    
    func enterBackground() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func becomeActive() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    // MARK: CLLocation delegate methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Update Locations")
        // only use last location
        if let coordiante = locations.last?.coordinate{
            print(coordiante)
            // send to local Database with flag needsUpload
            let locationPost: BOLocation = BOLocation.MR_createEntity()! as BOLocation
            locationPost.flagNeedsUpload = true
            locationPost.timestamp = NSDate()
            locationPost.latitude = coordiante.latitude as NSNumber
            locationPost.longitude = coordiante.longitude as NSNumber
            if CurrentUser.sharedInstance.currentTeamId() > -1 {
                locationPost.teamId = CurrentUser.sharedInstance.currentTeamId()
            }else{
                locationPost.teamId = -1
            }
            // Save
            locationPost.save()
            
            self.lastKnownLocation = locations.last
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_LOCATION_DID_UPDATE, object: nil)
            
            // ONLY FOR DEBUGGING
            #if DEBUG
                let notification = UILocalNotification()
                notification.fireDate = NSDate(timeIntervalSinceNow: 0)
                if UIApplication.sharedApplication().applicationState == UIApplicationState.Background {
                    notification.alertTitle = "App in Background"
                }else{
                    notification.alertTitle = "App in Foreground"
                }
                notification.alertBody = "Location Did Change!"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            #endif
        }
        // stop updating locations. Optional.
        // locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status{
        case .AuthorizedAlways:
            print("location tracking status always")
        case .Denied:
            print("location tracking status denied")
            locationManager.stopUpdatingLocation()
        case .NotDetermined:print("location tracking status not determined")
        case .Restricted:print("location tracking status restricted")
        default:break
        }
    }

}
