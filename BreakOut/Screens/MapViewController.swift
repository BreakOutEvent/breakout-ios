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

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!

    //MARK: Properties
    fileprivate var coordinateArray : [CLLocationCoordinate2D] = []
    fileprivate var polyLineArray : [MKPolyline] = []
    fileprivate var strokeColor = UIColor(red:0.35, green:0.67, blue:0.65, alpha:1.00)
    fileprivate let colorsForEvent = [1: UIColor(red:0.35, green:0.67, blue:0.65, alpha:1.00), 2: UIColor.red]
    fileprivate var selectedEvents = [Int]()
    /** This MapViewController is also used by TeamViewController, which itself sets this property.
     Dependent on wheather this property was set or not, we display map annotations at all locations 
     of postings or only one annotation at the last known location.
     */
    var teamController: TeamViewController?
    
    // MARK: Computed properties
    fileprivate var locationsByEvent = [Int : [TeamLocations]]() {
        didSet {
            drawLocationsForAllEventsOnMap()
        }
    }
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.mapType = .standard
        mapView.delegate = self
        
        if let teamController = teamController {
            if let team = teamController.team {
                loadAllLocationsForTeam(team: team)
            } else {
                // closure is executed if a team was set in teamController
                teamController >>> { $0.team | self.loadAllLocationsForTeam }
            }
        } else {
            loadIdsOfAllEvents()
        }
    
        // Style the navigation bar
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .mainOrange
        navigationController?.navigationBar.backgroundColor = .mainOrange
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        title = "mapTitle".local
        
        let leftButton = UIBarButtonItem(image: UIImage(named: "menu_Icon_black"), style: UIBarButtonItemStyle.done, target: self, action: #selector(showSideBar))
        navigationItem.leftBarButtonItem = leftButton
        
        //TO DO: right button for filtering
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Tracking
        super.viewDidAppear(animated)
        Flurry.logEvent("/MapViewController", timed: true)
        Answers.logCustomEvent(withName: "/MapViewController", customAttributes: [:])
    }
    
    
    
    // MARK: User functions
    
    private func loadIdsOfAllEvents() {
        Event.all().onSuccess { [weak weakSelf = self] events in
            weakSelf?.selectedEvents = events => { $0.id }
            events => {
                weakSelf?.loadAllLocationsForEvent($0.id)
            }
        }
    }
    
    private func loadAllLocationsForEvent(_ eventId: Int) {
        TeamLocations.all(for: eventId).onSuccess { [weak weakSelf = self] locations in
            weakSelf?.locationsByEvent[eventId] = locations
        }
    }
    
    private func loadAllLocationsForTeam(team: Team) {
        TeamLocations.locations(forTeam: team).onSuccess { [weak weakSelf = self] locations in
            weakSelf?.locationsByEvent = [team.event : [locations]]
        }
    }
    
    
    /**
     loops through event dictionary containing all locations for all events and teams and calls drawLocationsForTeamOnMap for each teamId.
     - parameter locationsForEventsAndTeams: Dictionary with first parameter as eventId , second as teamId
     */
    private func drawLocationsForAllEventsOnMap() {
        for (eventId, teams) in locationsByEvent {
            strokeColor = colorsForEvent[eventId] ?? .black
            for team in teams {
                drawLocationsForTeamOnMap(team)
            }
        }
    }
    
    /**
     loops through all locations in location-Array and add them to MapView as Annotation.
     - parameter location: Array of MapLocation
     */
    private func drawLocationsForTeamOnMap(_ locations: TeamLocations) {
        
        let shoulAnnotateAll = teamController != nil
        
        let locationArray = locations.mapLocations()
        for location in locationArray {
            coordinateArray.append(location.coordinate)
        }
        
        let polyLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
        coordinateArray.removeAll()
        mapView.add(polyLine)
        if shoulAnnotateAll {
            for location in locationArray where location.posting != nil {
                mapView.addAnnotation(location)
            }
        } else {
            mapView.addAnnotation(locationArray.last!)
        }
    }
    
    // MARK: Selector functions
    
    func showSideBar(){
        self.slideMenuController()?.toggleLeft()
    }
    
    // MARK: IBActions
    
    @IBAction func currentLocationButtonPressed(_ sender: UIButton) {
        let center = mapView.userLocation.coordinate
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        if center.longitude != 0 && center.latitude != 0 {
            mapView.setRegion(region, animated: true)
        }
    }
    

}



extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let pr = MKPolylineRenderer(overlay: overlay)
        pr.strokeColor = strokeColor
        pr.lineWidth = 2
        return pr
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "PostingLocation"
        
        if let annotation = annotation as? MapLocation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                if annotation.posting != nil {
                    let btn = UIButton(type: .detailDisclosure)
                    annotationView!.rightCalloutAccessoryView = btn
                }
            }
            annotationView!.annotation = annotation
            
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let mapLocationAnnotation = view.annotation as! MapLocation
        
        mapLocationAnnotation.post().onSuccess { posting in
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let postingDetailsTableViewController: PostingDetailsTableViewController = storyboard.instantiateViewController(withIdentifier: "PostingDetailsTableViewController") as! PostingDetailsTableViewController
            
            postingDetailsTableViewController.posting = posting
            
            (self.navigationController ?? self.teamController?.navigationController)?.pushViewController(postingDetailsTableViewController, animated: true)
        }
        
    }
}
