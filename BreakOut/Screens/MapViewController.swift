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
import Sweeft

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
    
    var arrayOfAllPostingAnnotations: [MapLocation] = [MapLocation]()
    var arrayOfAllLastPostingAnnotations: [MapLocation] = [MapLocation]()
    
    var switchButton: UISwitch?
    
    
    
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.mapType = .standard
            mapView.delegate = self
        }
    }
    

    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch locations
        fetchLocations()
        
        // Style the navigation bar
        self.navigationController!.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.barTintColor = Style.mainOrange
        self.navigationController!.navigationBar.backgroundColor = Style.mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.title = "Map"
        
        self.switchButton = UISwitch()
        self.switchButton!.addTarget(self, action: #selector(drawAllPostingsToMap), for: UIControlEvents.touchUpInside)
        
        // Create refresh button for navigation item
        //let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(drawAllPostingsToMap))
        let rightButton = UIBarButtonItem(customView: switchButton!)
        let leftButton = UIBarButtonItem(image: UIImage(named: "menu_Icon_black"), style: UIBarButtonItemStyle.done, target: self, action: #selector(showSideBar))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem = leftButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationDidUpdate), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_LOCATION_DID_UPDATE), object: nil)
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
    
    override func viewDidAppear(_ animated: Bool) {
        // Tracking
        Flurry.logEvent("/MapViewController", timed: true)
        Answers.logCustomEvent(withName: "/MapViewController", customAttributes: [:])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Flurry.endTimedEvent("/MapViewController", withParameters: nil)
    }
    
    func drawAllPostingsToMap() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        if self.switchButton!.isOn {
            self.mapView.addAnnotations(self.arrayOfAllPostingAnnotations)
        }else{
            self.mapView.addAnnotations(self.arrayOfAllLastPostingAnnotations)
        }
        
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
    
    func loadIdsOfAllEvents() {
        Event.all().onSuccess { events in
            events => {
                self.loadAllTeamsForEvent($0.id)
            }
        }
    }
    
    func loadAllTeamsForEvent(_ eventId: Int) {
        Team.all(for: eventId).onSuccess { teams in
            teams.array(withFirst: 10) => {
                self.loadAllPostingsForTeam(eventId, teamId: $0.id)
//                self.loadAllLocationsForTeam(eventId, teamId: $0.id)
            }
        }
    }
    
    func loadAllPostingsForTeam(_ eventId: Int, teamId: Int) {
        Post.get(team: teamId, event: eventId).onSuccess { posts in
            let posts = posts.array(withFirst: 10)
            let coordinateArray = posts ==> { $0.location?.coordinates }
            let locations = posts ==> { ($0, $0?.location?.coordinates) } >>> iff => { (post: Post, coordinate: CLLocationCoordinate2D) -> MapLocation in
                let location = MapLocation(coordinate: coordinate, title: post.participant.team?.name, subtitle: post.date.toString())
                location.posting = post
                return location
            }
            
            self.arrayOfAllPostingAnnotations.append(contentsOf: locations)
            self.arrayOfAllLastPostingAnnotations += [locations.first].flatMap { $0 }
            
            let polyLine = MKPolyline(coordinates: coordinateArray, count: coordinateArray.count)
            DispatchQueue.main.async {
                self.mapView.add(polyLine)
            }
        }
    }
    
    func loadAllLocationsForTeam(_ eventId: Int, teamId: Int) {
        Location.all(forTeam: teamId, event: eventId).onSuccess { locations in
            let coordinateArray = locations => { $0.coordinates }
            let polyLine = MKPolyline(coordinates: coordinateArray, count: coordinateArray.count)
            DispatchQueue.main.async {
                self.mapView.add(polyLine)
            }
        }
    }
    
    func locationDidUpdate() {
        self.lastCurrentLocation = BOLocationManager.shared.lastKnownLocation!
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
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
        self.loadIdsOfAllEvents()
    }
    /**
     loops through all locations in location-Array and add them to MapView as Annotation.
     - parameter location: Array of MapLocation
     */
    fileprivate func drawLocationsOnMap(_ locationsForTeams:[[MapLocation]]){
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        for locations in locationsForTeams{
            print("==============================")
            print("Number of locations for Teams: ", locationsForTeams.count)
            print("Number of locations: ", locations.count)
            print("First location title: ", locations.first!.title)
            print("First location coordinates: ", locations.first!.coordinate)
            print("==============================")
            //mapView.addAnnotation(locations.first!)
            for location in locations{
                coordinateArray.append(location.coordinate)
            }
            let polyLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
            polyLineArray.append(polyLine)
            coordinateArray.removeAll()
            
        }
        for polyLine in polyLineArray{
            mapView.add(polyLine)
        }
        polyLineArray.removeAll()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 1
        let identifier = "PostingLocation"
        
        // 2
        if annotation is MapLocation {
            // 3
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                //4
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                // 5
                let btn = UIButton(type: .detailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            } else {
                // 6
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        
        // 7
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let mapLocationAnnotation = view.annotation as! MapLocation
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let postingDetailsTableViewController: PostingDetailsTableViewController = storyboard.instantiateViewController(withIdentifier: "PostingDetailsTableViewController") as! PostingDetailsTableViewController
        
        postingDetailsTableViewController.posting = mapLocationAnnotation.posting
        
        self.navigationController?.pushViewController(postingDetailsTableViewController, animated: true)
    }
    
    @IBAction func currentLocationButtonPressed(_ sender: UIButton) {
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
