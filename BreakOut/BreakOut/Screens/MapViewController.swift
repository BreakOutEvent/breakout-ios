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
    
    var arrayOfAllPostingAnnotations: [MapLocation] = [MapLocation]()
    var arrayOfAllLastPostingAnnotations: [MapLocation] = [MapLocation]()
    
    var switchButton: UISwitch?
    
    
    
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
        
        self.switchButton = UISwitch()
        self.switchButton!.addTarget(self, action: #selector(drawAllPostingsToMap), forControlEvents: UIControlEvents.TouchUpInside)
        
        // Create refresh button for navigation item
        //let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(drawAllPostingsToMap))
        let rightButton = UIBarButtonItem(customView: switchButton!)
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
    
    func drawAllPostingsToMap() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        if self.switchButton!.on {
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
        BONetworkManager.doJSONRequestGET(.Event, arguments: [], parameters: nil, auth: false, success: { (response) in
            for newEvent: NSDictionary in response as! Array {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    self.loadAllTeamsForEvent(newEvent.valueForKey("id")as! Int)
                })
            }
        }) { (error, response) in
        }
    }
    
    func loadAllTeamsForEvent(eventId: Int) {
        BONetworkManager.doJSONRequestGET(.EventTeam, arguments: [eventId], parameters: nil, auth: false, success: { (response) in
            // response is an Array of Team Objects
            for newTeam: NSDictionary in response as! Array {
                let teamId: Int = newTeam.objectForKey("id") as! Int
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    self.loadAllPostingsForTeam(eventId, teamId: teamId)
                })
            }
            //BOToast.log("Downloading all postings was successful \(numberOfAddedPosts)")
            // Tracking
            //Flurry.logEvent("/posting/download/completed_successful", withParameters: ["API-Path":"GET: posting/", "Number of downloaded Postings":numberOfAddedPosts])
        }) { (error, response) in
            // TODO: Handle Errors
            //Flurry.logEvent("/posting/download/completed_error", withParameters: ["API-Path":"GET: posting/"])
        }
    }
    
    func loadAllPostingsForTeam(eventId: Int, teamId: Int) {
        var teamLocationsArray: Array<Location> = Array()
        BONetworkManager.doJSONRequestGET(.PostingIdsForTeam, arguments: [eventId,teamId], parameters: nil, auth: false, success: { (response) in
            
            let arrayOfIds = response as! [Int]
            
            if arrayOfIds.count > 0 {
            
            BONetworkManager.doJSONRequestPOST(.NotLoadedPostings, arguments: [], parameters: arrayOfIds, auth: false, success: { (response) in
                
                if let responseArray = response as? Array<NSDictionary> {
                    var counter: Int = 0
                    for postingDict in responseArray {
                        
                                if let locationDict = postingDict.objectForKey("postingLocation") as? NSDictionary {
                                    if let isDuringEvent = locationDict.objectForKey("duringEvent") as? Bool {
                                        if isDuringEvent {
                                            
                                            let newLocation = Location(dict: locationDict)
                                            teamLocationsArray.append(newLocation)
                                            
                                            let newPosting: Posting = Posting(dict: postingDict)
                                            let location = MapLocation(coordinate: CLLocationCoordinate2DMake(newLocation.latitude!.doubleValue, newLocation.longitude!.doubleValue), title: newLocation.teamName, subtitle: newLocation.timestamp!.toNaturalString(NSDate()))
                                            location.posting = newPosting
                                            
                                            if counter == 0 {
                                                self.mapView.addAnnotation(location)
                                                self.arrayOfAllLastPostingAnnotations.append(location)
                                            }
                                            self.arrayOfAllPostingAnnotations.append(location)
                                        }
                                    }
                                }
                        
                        
                        counter += 1
                    }
                    
                    var coordinateArray : [CLLocationCoordinate2D] = []
                    for location in teamLocationsArray{
                        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (location.latitude?.doubleValue)!, longitude: (location.longitude?.doubleValue)!)
                        coordinateArray.append(coordinate)
                    }
                    let polyLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.mapView.addOverlay(polyLine)
                    }
                }
            })
            }
        })
    }
    
    func loadAllLocationsForTeam(eventId: Int, teamId: Int) {
        var teamLocationsArray: Array<Location> = Array()
        BONetworkManager.doJSONRequestGET(.EventTeamLocation, arguments: [eventId,teamId], parameters: nil, auth: false, success: { (response) in
            
            if let responseArray = response as? Array<NSDictionary> {
                for locationDict in responseArray {
                    let newLocation = Location(dict: locationDict)
                    teamLocationsArray.append(newLocation)
                }
                
                var coordinateArray : [CLLocationCoordinate2D] = []
                for location in teamLocationsArray{
                    let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (location.latitude?.doubleValue)!, longitude: (location.longitude?.doubleValue)!)
                    coordinateArray.append(coordinate)
                }
                let polyLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.addOverlay(polyLine)
                }
            }
        })
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
        //self.navigationItem.rightBarButtonItem?.enabled = false
        //locationManager.startUpdatingLocation()
        /*blc.getAllLocationsForTeams { (locationsForTeams, error) in
            if error != nil{
                print("An error occured while fetching locations")
                print(error)
            }
            else{
                print("Received new locations from server:")
                self.drawLocationsOnMap(locationsForTeams!)
                
            }
        }*/
        self.loadIdsOfAllEvents()
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
            //mapView.addAnnotation(locations.first!)
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
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // 1
        let identifier = "PostingLocation"
        
        // 2
        if annotation is MapLocation {
            // 3
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            
            if annotationView == nil {
                //4
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                // 5
                let btn = UIButton(type: .DetailDisclosure)
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let mapLocationAnnotation = view.annotation as! MapLocation
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let postingDetailsTableViewController: PostingDetailsTableViewController = storyboard.instantiateViewControllerWithIdentifier("PostingDetailsTableViewController") as! PostingDetailsTableViewController
        
        //postingDetailsTableViewController.posting = (fetchedResultsController.objectAtIndexPath(indexPath) as! BOPost)
        postingDetailsTableViewController.posting = mapLocationAnnotation.posting
        
        self.navigationController?.pushViewController(postingDetailsTableViewController, animated: true)
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
