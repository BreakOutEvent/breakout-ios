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
    
    static let shared = BOLocationManager()
    
    var lastKnownLocation: CLLocation?
    
    let locationManager = CLLocationManager()
    
    func start() {
        // set delegate
        locationManager.delegate = self
        
        // aks user for permission
        let status = CLLocationManager.authorizationStatus()
        if status == .denied || status == .notDetermined || status == .authorizedWhenInUse || status == .restricted{
            locationManager.requestAlwaysAuthorization()
        }
        
        // set accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        // set distance filter in meters
        locationManager.distanceFilter = 3000
        
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Update Locations")
        // only use last location
        if let coordiante = locations.last?.coordinate{
            print(coordiante)
            // send to local Database with flag needsUpload
            let locationPost: BOLocation = BOLocation.mr_createEntity()! as BOLocation
            locationPost.flagNeedsUpload = true
            locationPost.timestamp = Date()
            locationPost.latitude = coordiante.latitude as NSNumber
            locationPost.longitude = coordiante.longitude as NSNumber
            if CurrentUser.shared.currentTeamId() > -1 {
                locationPost.teamId = CurrentUser.shared.currentTeamId()
            }else{
                locationPost.teamId = -1
            }
            // Save
            locationPost.save()
            
            self.lastKnownLocation = locations.last
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_LOCATION_DID_UPDATE), object: nil)
            
            // ONLY FOR DEBUGGING
            #if DEBUG
                let notification = UILocalNotification()
                notification.fireDate = Date(timeIntervalSinceNow: 0)
                if UIApplication.shared.applicationState == UIApplicationState.background {
                    notification.alertTitle = "App in Background"
                }else{
                    notification.alertTitle = "App in Foreground"
                }
                notification.alertBody = "Location Did Change!"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.scheduleLocalNotification(notification)
            #endif
        }
        // stop updating locations. Optional.
        // locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status{
        case .authorizedAlways:
            print("location tracking status always")
        case .denied:
            print("location tracking status denied")
            locationManager.stopUpdatingLocation()
        case .notDetermined:print("location tracking status not determined")
        case .restricted:print("location tracking status restricted")
        default:break
        }
    }

}
