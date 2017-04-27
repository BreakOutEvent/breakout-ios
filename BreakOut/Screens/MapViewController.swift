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
    
    var selectedEvents = [Int]()
    
    private var strokeColor = UIColor(red:0.35, green:0.67, blue:0.65, alpha:1.00)
    private let colorsForEvent = [1: UIColor(red:0.35, green:0.67, blue:0.65, alpha:1.00), 2: UIColor.red]
    
    var teamController: TeamViewController?
    
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
    
    @IBOutlet weak var filterViewOffset: NSLayoutConstraint!
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
        
        let leftButton = UIBarButtonItem(image: UIImage(named: "menu_Icon_black"), style: UIBarButtonItemStyle.done, target: self, action: #selector(showSideBar))
        navigationItem.leftBarButtonItem = leftButton
        
        if let teamController = teamController {
            title = "mapTitle".local
            if let team = teamController.team {
                set(team: team)
            } else {
                teamController >>> { $0.team | self.set }
            }
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
        loadAllLocationsForTeam(team: team)
    }
    
    func loadAllLocationsForEvent(_ eventId: Int) {
        TeamLocations.all(for: eventId).onSuccess { locations in
            self.locationsByEvent[eventId] = locations
        }
    }
    
    func loadAllLocationsForTeam(team: Team) {
        self.teamController?.navigationController?.navigationBar.startSpining()
        
        TeamLocations.locations(forTeam: team).onSuccess { locations in
            self.teamController?.navigationController?.navigationBar.stopSpinning()
            self.selectedEvents = [team.event]
            self.locationsByEvent = [team.event : [locations]]
        }
        .onError { _ in
            self.teamController?.navigationController?.navigationBar.stopSpinning()
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
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays |> { $0 is MKPolyline })
        for (eventId, teams) in locationsByEvent where selectedEvents.contains(eventId) {
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
            guard let lastLocation = locationArray.last else {
                return
            }
            mapView.addAnnotation(lastLocation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "PostingLocation"

        if let annotation = annotation as? MapLocation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
            }
            annotationView?.annotation = annotation
            if annotation.posting != nil {
                let btn = CommentButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = btn
            } else {
                annotationView?.rightCalloutAccessoryView = nil
            }
            
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let mapLocationAnnotation = view.annotation as! MapLocation
        let button = view.rightCalloutAccessoryView as? CommentButton
        button?.isLoading = true
        mapLocationAnnotation.post().onSuccess { posting in
            button?.isLoading = false
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
    
    @IBAction func didPressFilter(_ sender: Any) {
        let newHeight: CGFloat = filterViewOffset.constant == 0 ? -260 : 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.filterViewOffset.constant = newHeight
            self.view.layoutIfNeeded()
        }
        
    }
    
     func showSideBar(){
        self.slideMenuController()?.toggleLeft()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? EventSelectorViewController, teamController == nil {
            title = "mapTitle".local
            controller.delegate = self
        }
    }
    
}

extension MapViewController: EventSelectorDelegate {
    
    func eventSelector(_ eventSelector: EventSelectorViewController, didChange selected: [Int]) {
        selectedEvents = selected
        navigationController?.navigationBar.startSpining()
        let needed = selected - locationsByEvent.keys.array
        loadAllLocations(for: needed.array).onSuccess { locations in
            self.navigationController?.navigationBar.stopSpinning()
            self.locationsByEvent = self.locationsByEvent + locations
        }
        .onError { _ in
            self.navigationController?.navigationBar.stopSpinning()
        }
    }
    
}
