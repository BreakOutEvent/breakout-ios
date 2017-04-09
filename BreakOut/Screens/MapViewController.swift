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

    
    typealias LocationsByEvent = [Int : [TeamLocations]]
    
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
    var coordinateArray : [CLLocationCoordinate2D] = []
    var polyLineArray : [MKPolyline] = []
    
    private var strokeColor = UIColor(red:0.35, green:0.67, blue:0.65, alpha:1.00)
    private let colorsForEvent = [1: UIColor(red:0.35, green:0.67, blue:0.65, alpha:1.00), 2: UIColor.red]
    
    var teamController: TeamViewController?
    
    var selectedEvents = [Int]()
    
    var locationsByEvent = LocationsByEvent() {
        didSet {
            drawLocationsForAllEventsOnMap()
        }
    }
    
    func loadAllLocations(for events: [Int]) -> Promise<LocationsByEvent, APIError> {
        return BulkPromise(promises: events => { event in
            return TeamLocations.all(for: event).nested { (event, $0) }
        }).nested { $0.dictionary { $0 } }
    }
    
    @IBOutlet weak var mapView: MKMapView!

    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.mapType = .standard
        mapView.delegate = self
    
        // Style the navigation bar
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .mainOrange
        navigationController?.navigationBar.backgroundColor = .mainOrange
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        title = "mapTitle".local
        
        let leftButton = UIBarButtonItem(image: UIImage(named: "menu_Icon_black"), style: UIBarButtonItemStyle.done, target: self, action: #selector(showSideBar))
        navigationItem.leftBarButtonItem = leftButton
        
        if let teamController = teamController {
            if let team = teamController.team {
                set(team: team)
            } else {
                teamController >>> { $0.team | self.set }
            }
        } else {
            // Fetch locations
            loadIdsOfAllEvents()
        }
        
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
    
    func set(team: Team) {
        loadAllLocationsForTeam(team.event, teamId: team.id)
    }
    
    func loadIdsOfAllEvents() {
        navigationController?.navigationBar.startSpining()
        Event.all().onSuccess { events in
            self.loadAllLocations(for: events => { $0.id }).onSuccess { locations in
                .main >>> {
                    self.locationsByEvent = locations
                    self.navigationController?.navigationBar.stopSpinning()
                }
            }
            .onError { _ in
                // TODO: Error handling
                self.navigationController?.navigationBar.stopSpinning()
            }
        }
        
    }
    
    func loadAllLocationsForEvent(_ eventId: Int) {
        TeamLocations.all(for: eventId).onSuccess { locations in
            self.locationsByEvent[eventId] = locations
        }
    }
    
    func loadAllLocationsForTeam(_ eventId: Int, teamId: Int) {
        self.teamController?.navigationController?.navigationBar.startSpining()
        TeamLocations.locations(forTeam: teamId, event: eventId).onSuccess { locations in
            self.teamController?.navigationController?.navigationBar.stopSpinning()
            self.locationsByEvent = [eventId : [locations]]
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let pr = MKPolylineRenderer(overlay: overlay)
        pr.strokeColor = strokeColor
        pr.lineWidth = 2
        return pr
    }
    
    // MARK: selector functions
    let blc = BasicLocationController()
    
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
        let locationArray = locations.mapLocations()
        for location in locationArray {
            coordinateArray.append(location.coordinate)
        }
        
        let polyLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
        coordinateArray.removeAll()
        mapView.add(polyLine)
        guard let lastLocation = locationArray.last else {
            return
        }
        mapView.addAnnotation(lastLocation)
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
            } else {
                annotationView!.annotation = annotation
            }
            
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
