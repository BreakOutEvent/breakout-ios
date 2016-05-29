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

import Flurry_iOS_SDK
import Crashlytics

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
    var coordinateArray : [CLLocationCoordinate2D] = []
    var polyLineArray : [MKPolyline] = []
    //let locationManager = CLLocationManager()
    
    
    
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
        self.title = "Map"
        
        // Create refresh button for navigation item
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(fetchLocations))
        let leftButton = UIBarButtonItem(image: UIImage(named: "menu_Icon_black"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(showSideBar))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem = leftButton
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(fetchLocations), name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(locationDidUpdate), name: Constants.NOTIFICATION_LOCATION_DID_UPDATE, object: nil)
        /*
 
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
        */
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tracking
        Flurry.logEvent("/MapViewController", timed: true)
        Answers.logCustomEventWithName("/MapViewController", customAttributes: [:])
    }
    
    override func viewDidDisappear(animated: Bool) {
        Flurry.endTimedEvent("/MapViewController", withParameters: nil)
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
    
    func locationDidUpdate() {
        self.lastCurrentLocation = BOLocationManager.sharedInstance.lastKnownLocation!
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let pr = MKPolylineRenderer(overlay: overlay)
        //pr.strokeColor = UIColor(red:0.35, green:0.67, blue:0.65, alpha:1.00) // This is one of our CI colors
        pr.strokeColor = self.getRandomColor()
        pr.lineWidth = 2
        return pr
    }
    
    // MARK: selector functions
    let blc = BasicLocationController()
    
    /**
     Function gets called as selector of UIBarButtonItem.
     Fetches locations by invoking getAllLocations-method of BasicLocationController-class
     If now error occures, drawLocationsOnMap
     */
    func fetchLocations(){
        self.navigationItem.rightBarButtonItem?.enabled = false
        //locationManager.startUpdatingLocation()
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
        mapView.removeOverlays(mapView.overlays)
        for locations in locationsForTeams{
            print("==============================")
            print("Number of locations for Teams: ", locationsForTeams.count)
            print("Number of locations: ", locations.count)
            print("First location title: ", locations.first!.title)
            print("First location coordinates: ", locations.first!.coordinate)
            print("==============================")
            mapView.addAnnotation(locations.first!)
            for location in locations{
                coordinateArray.append(location.coordinate)
            }
            let polyLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
            polyLineArray.append(polyLine)
            coordinateArray.removeAll()
            
        }
        for polyLine in polyLineArray{
            mapView.addOverlay(polyLine)
        }
        polyLineArray.removeAll()
        
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    @IBAction func currentLocationButtonPressed(sender: UIButton) {
        //let center = CLLocationCoordinate2D(latitude: lastCurrentLocation.coordinate.latitude, longitude: lastCurrentLocation.coordinate.longitude)
        let center = mapView.userLocation.coordinate
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        if center.longitude != 0 && center.latitude != 0 {
            mapView.setRegion(region, animated: true)
        }
        
        
    }
    
     func showSideBar(){
        self.slideMenuController()?.toggleLeft()
    }
    
}
