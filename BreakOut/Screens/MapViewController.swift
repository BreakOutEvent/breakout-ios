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
import SpinKit
import MBProgressHUD

import Flurry_iOS_SDK
import Crashlytics

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: private properties
    private var locations = [MapLocation]()
    private var coordinateArray = [CLLocationCoordinate2D]()
    private var polyLineArray = [MKPolyline]()
    private let colorsForEvent = [1: UIColor(red:0.35, green:0.67, blue:0.65, alpha:1.00), 2: UIColor.red]
    private var strokeColor = UIColor(red:0.35, green:0.67, blue:0.65, alpha:1.00)
    private var loadingHUD: MBProgressHUD = MBProgressHUD()
    // MARK: Model
    /**
     Model for the MapView. This dictionary contains all locations for all events and all teams in a sorted fashion. First Int is eventId, second is teamId.
     */
    var eventDict = [Int:[Int:[MapLocation]]](){

        didSet{
            drawLocationsForAllEventsOnMap(eventDict)
            loadingHUD.hide(true)
        }
    }

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.mapType = .standard
            mapView.delegate = self
        }
    }
    
    
    
    // MARK: User Functions
    func showSideBar(){
        self.slideMenuController()?.toggleLeft()
    }
    
    func fetchNewBOLocationsSinceLastId(){
        // append location array in here.
        print("fetch new BOLocations since last Id")
    }
    
    // TO DO: show activation indicator
    func fetchAllLocationsForEvents(){
        BONetworkManager.get(.Event, arguments: [], parameters: nil, auth: false, success: { [weak weakSelf = self](response) in
            for newEvent: NSDictionary in response as! Array {
                if let id = newEvent.value(forKey: "id") as? Int{
                    DispatchQueue.global(qos: .background).async {
                        weakSelf?.loadAllLocationsForEvent(id: id)
                    }
                }
            }
        }) { (error, response) in
            Flurry.logError("ERROR_ID", message: "An error occured getEvent", error: error)
            self.loadingHUD.hide(true)
        }
    }
    
    
    // TO DO: Check if user still wants to see the locations or if he is already gone, then we don't need to draw at all.
    private func loadAllLocationsForEvent(id: Int){
        BONetworkManager.get(.EventAllLocations, arguments: [id], parameters: nil, auth: false) {[weak weakSelf = self](response) in
            if let response = response as? Array<NSDictionary>{
                weakSelf?.locations = weakSelf!.convertNSDictionaryToMapLocation(response).enumerated().flatMap { index, element in index % 2 == 1 ? nil : element }
            }
            let locationDictForTeams = weakSelf!.locations.groupBy {$0.teamId!}
            weakSelf?.eventDict[id] = locationDictForTeams
        }
        
    }
    
    /**
     converts response of server (JSON Objects as NSDictionaries) to MapLocations in order for them to be displayed on the map.
     Uses map-function on the dictionaries to extract longitude and latitude
     - parameter dict: response from server as NSDictionary
     - returns: Array of locations as MapLocation which can be displayed on map
     */
    private func convertNSDictionaryToMapLocation(_ dicts: Array<NSDictionary>) -> Array<MapLocation> {
        return dicts.map({ dict in extractLocation(dict) }).flatMap({ dict in dict })
        
    }
    
    /**
     extracts location information from each NSDictionary.
     Response dictionary contais all kind of information. Values of interest are just longitude and latitude
     - parameter dict: one NSDictionary from response
     - returns: location as MapLocation
     */
    private func extractLocation(_ dict: NSDictionary) -> MapLocation? {
        let longitude = dict.value(forKey: "longitude") as! CLLocationDegrees
        let latitude = dict.value(forKey: "latitude") as! CLLocationDegrees
        let teamName = dict.value(forKey: "team") as! String
        let teamId = dict.value(forKey: "teamId") as! Int
        let distance = dict.value(forKey: "distance") as! Int
        let title =  "# \(teamId): " + teamName
        let location = MapLocation(latitude: latitude, longitude: longitude, title: title)
        location.teamId = teamId
        location.subtitle = "distance: \(distance) km"
        return location
    }
    
    /**
     loops through event dictionary containing all locations for all events and teams and calls drawLocationsForTeamOnMap for each teamId.
     - parameter locationsForEventsAndTeams: Dictionary with first parameter as eventId , second as teamId
     */
    private func drawLocationsForAllEventsOnMap(_ locationsForEventsAndTeams:[Int:[Int:[MapLocation]]]){
        for (eventId, dictForTeams) in locationsForEventsAndTeams{
            strokeColor = colorsForEvent[eventId] ?? UIColor.black
            for (teamIds, locations) in dictForTeams{
                print("==============================")
                print("Event Id: ", eventId)
                print("Team Id: ", teamIds)
                print("Number of Teams: ", dictForTeams.count)
                print("Number of locations: ", locations.count)
                print("==============================")
                drawLocationsForTeamOnMap(locations)
            }
        }
    }
    
    /**
     loops through all locations in location-Array and add them to MapView as Annotation.
     - parameter location: Array of MapLocation
     */
    private func drawLocationsForTeamOnMap(_ locationArray:[MapLocation]){
//        mapView.removeAnnotations(mapView.annotations)
//        mapView.removeOverlays(mapView.overlays)
        
        for location in locationArray{
            coordinateArray.append(location.coordinate)
        }
        
        let polyLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
        coordinateArray.removeAll()
        mapView.add(polyLine)
        mapView.addAnnotation(locationArray.last!)
    }


    private func setupLoadingHUD(_ localizedKey: String) {
        let spinner: RTSpinKitView = RTSpinKitView(style: RTSpinKitViewStyle.style9CubeGrid, color: UIColor.white, spinnerSize: 37.0)
        self.loadingHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loadingHUD.isSquare = true
        self.loadingHUD.mode = MBProgressHUDMode.customView
        self.loadingHUD.customView = spinner
        self.loadingHUD.labelText = NSLocalizedString(localizedKey, comment: "loading")
        spinner.startAnimating()
    }
    
   // MARK: Delegate Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let identifier = "Location"
        
        if annotation is MapLocation {

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {

                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                

                let btn = UIButton(type: .detailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            } else {

                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        
        return nil
    }
    

    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let pr = MKPolylineRenderer(overlay: overlay)
        pr.strokeColor = strokeColor
        pr.lineWidth = 2
        return pr
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style the navigation bar
        self.navigationController!.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.barTintColor = Style.mainOrange
        self.navigationController!.navigationBar.backgroundColor = Style.mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.title = "Map"
        
        setupLoadingHUD("Loading ...")
        fetchAllLocationsForEvents()
        // Buttons in navigation bar
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(fetchNewBOLocationsSinceLastId))
        // switch button. Addes during event to reduce load.
        // let rightButton = UIBarButtonItem(customView: switchButton!)
        // burger button
        let leftButton = UIBarButtonItem(image: UIImage(named: "menu_Icon_black"), style: UIBarButtonItemStyle.done, target: self, action: #selector(showSideBar))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem = leftButton
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(fetchNewBOLocationsSinceLastId), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        //
        //        NotificationCenter.default.addObserver(self, selector: #selector(locationDidUpdate), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_LOCATION_DID_UPDATE), object: nil)
        
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
