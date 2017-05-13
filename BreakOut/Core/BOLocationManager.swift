//
//  BOLocationManager.swift
//  BreakOut
//
//  Created by Leo Käßner on 25.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import CoreLocation

// Tracking
import Flurry_iOS_SDK
import Crashlytics

class BOLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = BOLocationManager()
    
    var lastKnownLocation: CLLocation?
    
    var shouldMonitorLocation: Bool {
        return CurrentUser.shared.isLoggedIn() && CurrentUser.shared.currentTeamId() >= 0
    }
    
    let locationManager = CLLocationManager()
    
    func start() {
        // set delegate
        locationManager.delegate = self
        
        // aks user for permission
        let status = CLLocationManager.authorizationStatus()
        if status == .denied || status == .notDetermined || status == .authorizedWhenInUse || status == .restricted {
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
        if CLLocationManager.locationServicesEnabled(), shouldMonitorLocation {
            print("location Services are enabled. Start Updating Locations ...")
            locationManager.startUpdatingLocation()
        }
    }
    
    func enterBackground() {
        if shouldMonitorLocation {
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func becomeActive() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    // MARK: CLLocation delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Update Locations")
        
        if let coordiante = locations.last?.coordinate, CurrentUser.shared.currentTeamId() > -1 {
            let event = CurrentUser.shared.currentEventId()
            let team = CurrentUser.shared.currentTeamId()
            Location.update(coordinates: coordiante, event: event, team: team).onSuccess { _ in
                print("Location Sent!")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status{
        case .authorizedAlways:
            print("location tracking status always")
        case .denied:
            print("location tracking status denied")
            locationManager.stopUpdatingLocation()
        case .notDetermined:
            print("location tracking status not determined")
        case .restricted:
            print("location tracking status restricted")
        default:break
        }
    }

}
