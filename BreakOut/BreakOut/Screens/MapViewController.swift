//
//  MapViewController.swift
//  BreakOut
//
//  Created by David Symhoven on 01.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MagicalRecord

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    // TODO
    // > fetch user location from backend -> should work
    // > delete dummy user.swift
    // > add sideView in annotations
    // > set alpha of navigationbar background
    // > send locations to databse
    
    //MARK: Properties and Outlets
    let initalLocation = CLLocation(latitude: 48.13842, longitude: 11.57917)
    var lastCurrentLocation = CLLocation()
    let regionRadius : CLLocationDistance = 5000
    var users = [User]()
    let locationManager = CLLocationManager()
    
    
    
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.mapType = .Standard
            mapView.delegate = self
        }
    }
    

    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch locations
        fetchLocations()
        
        // Style the navigation bar
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.navigationBar.barTintColor = Style.mainOrange
        self.navigationController!.navigationBar.backgroundColor = Style.mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.title = "MapView"
        
        // Create refresh button for navigation item
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(fetchLocations))
        let leftButton = UIBarButtonItem(image: UIImage(named: "menu_Icon_black"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(showSideBar))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem = leftButton
        
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
            
            lastCurrentLocation = locations.last!
        }
        // stop updating locations. Optional.
        // locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status{
        case .AuthorizedAlways:
            print("location tracking status always")
            mapView.showsUserLocation = true;
        case .Denied:
            print("location tracking status denied")
            locationManager.stopUpdatingLocation()
        case .NotDetermined:print("location tracking status not determined")
        case .Restricted:print("location tracking status restricted")
        default:break
        }
        
    }
    // MARK: selector functions
    let blc = BasicLocationController()
    
    /**
     Function gets called as selector of UIBarButtonItem.
     Fetches locations by invoking getAllLocations-method of BasicLocationController-class
     If now error occures, drawLocationsOnMap
     */
    func fetchLocations(){
        locationManager.startUpdatingLocation()
        blc.getAllLocationsForTeams { (locationsForTeams, error) in
            if error != nil{
                print("An error occured while fetching locations")
                print(error)
            }
            else{
                print("Received new locations from server:")
                self.drawLocationsOnMap(locationsForTeams!)
                
            }
        }
            
        }
    /**
     loops through all locations in location-Array and add them to MapView as Annotation.
     - parameter location: Array of MapLocation
     */
    private func drawLocationsOnMap(locationsForTeams:[[MapLocation]]){
        mapView.removeAnnotations(mapView.annotations)
        for locations in locationsForTeams{
            print("==============================")
            print("Number of locations for Teams: ", locationsForTeams.count)
            print("Number of locations: ", locations.count)
            print("First location title: ", locations.first!.title)
            print("First location coordinates: ", locations.first!.coordinate)
            print("==============================")
            mapView.addAnnotation(locations.first!)
        }
    }
    
    @IBAction func currentLocationButtonPressed(sender: UIButton) {
        let center = CLLocationCoordinate2D(latitude: lastCurrentLocation.coordinate.latitude, longitude: lastCurrentLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
    }
    
     func showSideBar(){
        self.slideMenuController()?.toggleLeft()
    }
    
}
