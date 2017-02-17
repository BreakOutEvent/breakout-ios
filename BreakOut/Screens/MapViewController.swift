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
    
    // Model
    //    var locations: [MapLocation] = []{
    //        didSet{
    //            updateMap()
    //        }
    //    }
    
    private var locations = [MapLocation]()
    var coordinateArray = [CLLocationCoordinate2D]()
    var polyLineArray = [MKPolyline]()
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.mapType = .standard
            mapView.delegate = self
        }
    }
    
    
    func showSideBar(){
        self.slideMenuController()?.toggleLeft()
    }
    
    func fetchNewBOLocationsSinceLastId(){
        // append location array in here.
        print("fetch new BOLocations since last Id")
    }
    
    func updateMap(){
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
        }
    }
    
    
    private var test = [Int:[Int:[MapLocation]]]()
    
    private func loadAllLocationsForEvent(id: Int){
        BONetworkManager.get(.EventAllLocations, arguments: [id], parameters: nil, auth: false) {[weak weakSelf = self](response) in
            if let response = response as? Array<NSDictionary>{
                weakSelf?.locations = weakSelf!.convertNSDictionaryToMapLocation(response)
            }
            let locationDictForTeams = weakSelf!.locations.groupBy {$0.teamId!}
            weakSelf?.test[id] = locationDictForTeams
            weakSelf?.drawLocationsOnMap(weakSelf!.test)
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
        let title = dict.value(forKey: "team") as! String
        let location = MapLocation(latitude: latitude, longitude: longitude, title: title)
        location.teamId = dict.value(forKey: "teamId") as? Int
        return location
    }
    
    /**
     loops through all locations in location-Array and add them to MapView as Annotation.
     - parameter location: Array of MapLocation
     */
    fileprivate func drawLocationsOnMap(_ locationsForEventsAndTeams:[Int:[Int:[MapLocation]]]){
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        for (eventIds, dictForTeams) in locationsForEventsAndTeams{
            for (teamIds, locations) in dictForTeams{
                print("==============================")
                print("Event Id: ", eventIds)
                print("Team Id: ", teamIds)
                print("Number of Teams: ", dictForTeams.count)
                print("Number of locations: ", locations.count)
                print("==============================")
                for location in locations{
                    coordinateArray.append(location.coordinate)
                }
                
            }
            let polyLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
            polyLineArray.append(polyLine)
            coordinateArray.removeAll()
            
        }
        for polyLine in polyLineArray{
            mapView.add(polyLine)
        }
        polyLineArray.removeAll()
        
//        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 1
        let identifier = "Location"
        
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
    

    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let pr = MKPolylineRenderer(overlay: overlay)
        pr.strokeColor = UIColor(red:0.35, green:0.67, blue:0.65, alpha:1.00) // This is one of our CI colors
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
        updateMap()
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
