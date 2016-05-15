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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    // TODO
    // > fetch user location from backend -> should work
    // > delete dummy user.swift
    // > add sideView in annotations
    // > set alpha of navigationbar background
    // > send locations to databse
    
    //MARK: Properties and Outlets
    let initalLocation = CLLocation(latitude: 48.13842, longitude: 11.57917)
    let regionRadius : CLLocationDistance = 5000
    var users = [User]()
    let locationManager = CLLocationManager()
    
    
    
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.mapType = .Standard
            mapView.delegate = self
            createUserArray()
            for name in users{
                mapView.addAnnotation(name)
            }
        }
    }
    
    // MARK: Dummy Data.
    func createUserArray(){
        let David = User(name: "David", locationName: "München", coordinate: CLLocationCoordinate2D(latitude: 48.099656, longitude: 11.531533))
        let Florian = User(name: "Florian", locationName: "Dresden", coordinate: CLLocationCoordinate2D(latitude: 51.050409, longitude: 13.737262))
        users.append(David)
        users.append(Florian)
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        locationManager.requestAlwaysAuthorization()
        
        // set accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        // start monitoring
        if CLLocationManager.locationServicesEnabled(){
            print("location Services are enabled")
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
        }
        // stop updating locations
        locationManager.stopUpdatingLocation()
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
        blc.getAllLocations { (locations, error) in
            if error != nil{
                print("An error occured")
                print(error)
            }
            else{
                print("got here. Location:")
                print(locations?.last!.coordinate)
                self.drawLocationsOnMap(locations!)
                
            }
        }
            
        }
    /**
     loops through all locations in location-Array and add them to MapView as Annotation.
     - parameter location: Array of MapLocation
     */
    private func drawLocationsOnMap(location:[MapLocation]){
        for places in location{
            mapView.addAnnotation(places)
        }
    }
    
    func showSideBar(){
        print("MenuButton pressed")
        self.slideMenuController()?.toggleLeft()
    }
    
}
