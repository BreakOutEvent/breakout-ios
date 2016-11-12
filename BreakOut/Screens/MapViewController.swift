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
    
    //MARK: Properties
    let initalLocation = CLLocation(latitude: 48.13842, longitude: 11.57917)
    var lastCurrentLocation = CLLocation()
    let regionRadius : CLLocationDistance = 5000
    var users = [User]()
    var coordinateArray : [CLLocationCoordinate2D] = []
    var polyLineArray : [MKPolyline] = []
    var arrayOfAllPostingAnnotations: [MapLocation] = []
    var arrayOfAllLastPostingAnnotations: [MapLocation] = []
    var arrayOfAllEventIds : [Int] = []
    var switchButton: UISwitch?
    var locationArrayForAllEvents : [BOLocation] = []
    
    let basicLocationController = BasicLocationController()
    let locationSyncManager = BOLocationSyncManager()
    
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.mapType = .standard
            mapView.delegate = self
        }
    }
    

    

    // MARK: user functions
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
    
//    func loadIdsOfAllEvents() {
//        BONetworkManager.get(.Event, arguments: [], parameters: nil, auth: false, success: { (response) in
//            for newEvent: NSDictionary in response as! Array {
//                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
//                    self.loadAllTeamsForEvent(newEvent.value(forKey: "id")as! Int)
//                })
//            }
//        }) { (error, response) in
//        }
//    }

    func fetchAllLocationsAndSaveInCoreData() {
        BONetworkManager.get(.Event, arguments: [], parameters: nil, auth: false, success: { (response) in
            for newEvent: NSDictionary in response as! Array {
                if let eventId = newEvent.value(forKey: "id") as? Int{
                    self.arrayOfAllEventIds.append(eventId)
                }
                self.locationSyncManager.downloadArrayOfNewLocationsSinceLastKnownLocationFor(eventId: 1)
            }
        }) { (error, response) in
        }
    }
    
    
//    func loadAllTeamsForEvent(_ eventId: Int) {
//        BONetworkManager.get(.EventTeam, arguments: [eventId], parameters: nil, auth: false, success: { (response) in
//            // response is an Array of Team Objects
//            for newTeam: NSDictionary in response as! Array {
//                let teamId: Int = newTeam.object(forKey: "id") as! Int
//                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
//                    self.loadAllPostingsForTeam(eventId, teamId: teamId)
//                })
//            }
//            //BOToast.log("Downloading all postings was successful \(numberOfAddedPosts)")
//            // Tracking
//            //Flurry.logEvent("/posting/download/completed_successful", withParameters: ["API-Path":"GET: posting/", "Number of downloaded Postings":numberOfAddedPosts])
//        }) { (error, response) in
//            // TODO: Handle Errors
//            //Flurry.logEvent("/posting/download/completed_error", withParameters: ["API-Path":"GET: posting/"])
//        }
//    }
    
//    func loadAllPostingsForTeam(_ eventId: Int, teamId: Int) {
//        var teamLocationsArray: Array<Location> = Array()
//        BONetworkManager.get(.PostingIdsForTeam, arguments: [eventId,teamId], parameters: nil, auth: false, success: { (response) in
//            
//            let arrayOfIds = response as! [Int]
//            
//            if arrayOfIds.count > 0 {
//            
//            BONetworkManager.post(.NotLoadedPostings, arguments: [], parameters: arrayOfIds as AnyObject, auth: false, success: { (response) in
//                
//                if let responseArray = response as? Array<NSDictionary> {
//                    var counter: Int = 0
//                    for postingDict in responseArray {
//                        
//                                if let locationDict = postingDict.object(forKey: "postingLocation") as? NSDictionary {
//                                    if let isDuringEvent = locationDict.object(forKey: "duringEvent") as? Bool {
//                                        if isDuringEvent {
//                                            
//                                            let newLocation = Location(dict: locationDict)
//                                            teamLocationsArray.append(newLocation)
//                                            
//                                            let newPosting: Posting = Posting(dict: postingDict)
//                                            let location = MapLocation(coordinate: CLLocationCoordinate2DMake(newLocation.latitude!.doubleValue, newLocation.longitude!.doubleValue), title: newLocation.teamName, subtitle: newLocation.timestamp!.toString())
//                                            location.posting = newPosting
//                                            
//                                            if counter == 0 {
//                                                self.mapView.addAnnotation(location)
//                                                self.arrayOfAllLastPostingAnnotations.append(location)
//                                            }
//                                            self.arrayOfAllPostingAnnotations.append(location)
//                                        }
//                                    }
//                                }
//                        
//                        
//                        counter += 1
//                    }
//                    
//                    var coordinateArray : [CLLocationCoordinate2D] = []
//                    for location in teamLocationsArray{
//                        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (location.latitude?.doubleValue)!, longitude: (location.longitude?.doubleValue)!)
//                        coordinateArray.append(coordinate)
//                    }
//                    let polyLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
//                    DispatchQueue.main.async {
//                        self.mapView.add(polyLine)
//                    }
//                }
//            })
//            }
//        })
//    }
    
//    func loadAllLocationsForTeam(_ eventId: Int, teamId: Int) {
//        var teamLocationsArray: Array<Location> = Array()
//        BONetworkManager.get(.EventTeamLocation, arguments: [eventId,teamId], parameters: nil, auth: false, success: { (response) in
//            
//            if let responseArray = response as? Array<NSDictionary> {
//                for locationDict in responseArray {
//                    let newLocation = Location(dict: locationDict)
//                    teamLocationsArray.append(newLocation)
//                }
//                
//                var coordinateArray : [CLLocationCoordinate2D] = []
//                for location in teamLocationsArray{
//                    let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (location.latitude?.doubleValue)!, longitude: (location.longitude?.doubleValue)!)
//                    coordinateArray.append(coordinate)
//                }
//                let polyLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
//                DispatchQueue.main.async {
//                    self.mapView.add(polyLine)
//                }
//            }
//        })
//    }
    
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
    

    
    /**
     Function gets called as selector of UIBarButtonItem.
     Fetches locations by invoking getAllLocations-method of BasicLocationController-class
     If now error occures, drawLocationsOnMap
     */
    func fetchNewBOLocationsSinceLastId(){
        if let lastKnownBOLocationId = locationArrayForAllEvents.last?.uid{
            // fetch here all new BOLocations since last Id somehow with NSPredicate
            print(lastKnownBOLocationId)
        }
        extractMapLocations()
        
        //let locationArray = basicLocationController.getAllLocationsForEvents()
        //locationSyncManager.downloadArrayOfNewLocationsSinceLastKnownLocation()
        //self.navigationItem.rightBarButtonItem?.enabled = false
        //locationManager.startUpdatingLocation()
//        basicLocationController.getAllLocationsForTeams { (locationsForTeams, error) in
//            if error != nil{
//                print("An error occured while fetching locations")
//                print(error as Any)
//            }
//            else{
//                print("Received new locations from server:")
//                self.drawLocationsOnMap(locationsForTeams!)
//                
//            }
//        }
        //self.loadIdsOfAllEvents()
    }
    
    func extractMapLocations(){
        let locationDictionaryForEvents = locationArrayForAllEvents.groupBy {$0.uid}
        let numberOFEvents = locationDictionaryForEvents.count
        var locationDictionaryForTeams : [Int:[BOLocation]] = [:]
        for eventID in 1...numberOFEvents{
            locationDictionaryForTeams[eventID] = locationDictionaryForEvents[eventID]

        }
        //locationDictionaryForTeams
        let mapLocationsArrayForAllEvents = locationArrayForAllEvents.map{MapLocation(latitude: $0.longitude as CLLocationDegrees, longitude: $0.latitude as CLLocationDegrees, title: $0.teamName)}
        
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
        
        //postingDetailsTableViewController.posting = (fetchedResultsController.objectAtIndexPath(indexPath) as! BOPost)
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
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch all Event Ids and use them to fetch all locations from the backend
        fetchAllLocationsAndSaveInCoreData()
        
        // get all Locations saved in CoreData
        locationArrayForAllEvents = basicLocationController.getAllLocationsForEvents()
        
        // Style the navigation bar
        self.navigationController!.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.barTintColor = Style.mainOrange
        self.navigationController!.navigationBar.backgroundColor = Style.mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.title = "Map"
        
        //self.switchButton = UISwitch()
        //self.switchButton!.addTarget(self, action: #selector(drawAllPostingsToMap), for: UIControlEvents.touchUpInside)
        
        // Buttons in navigation bar
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(fetchNewBOLocationsSinceLastId))
        // switch button. Addes during event to reduce load.
        // let rightButton = UIBarButtonItem(customView: switchButton!)
        // burger button
        let leftButton = UIBarButtonItem(image: UIImage(named: "menu_Icon_black"), style: UIBarButtonItemStyle.done, target: self, action: #selector(showSideBar))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem = leftButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchNewBOLocationsSinceLastId), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationDidUpdate), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_LOCATION_DID_UPDATE), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Tracking
        Flurry.logEvent("/MapViewController", timed: true)
        Answers.logCustomEvent(withName: "/MapViewController", customAttributes: [:])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Flurry.endTimedEvent("/MapViewController", withParameters: nil)
    }
}
