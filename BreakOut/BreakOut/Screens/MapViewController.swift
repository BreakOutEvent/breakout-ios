//
//  MapViewController.swift
//  BreakOut
//
//  Created by David Symhoven on 01.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    // dummy Data
    // TODO: 
    // > fetch user location from backend
    // > delete dummy user.swift
    // > add sideView in annotations
    // > set alpha of navigationbar background
    
    let initalLocation = CLLocation(latitude: 48.13842, longitude: 11.57917)
    let regionRadius : CLLocationDistance = 5000
    var users = [User]()
    
    
    
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
    
    
    func createUserArray(){
        let David = User(name: "David", locationName: "München", coordinate: CLLocationCoordinate2D(latitude: 48.099656, longitude: 11.531533))
        let Florian = User(name: "Florian", locationName: "Dresden", coordinate: CLLocationCoordinate2D(latitude: 51.050409, longitude: 13.737262))
        users.append(David)
        users.append(Florian)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Style the navigation bar
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.navigationBar.barTintColor = Style.mainOrange
        self.navigationController!.navigationBar.backgroundColor = Style.mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]

        self.title = "MapView"
        
        // Create save button for navigation item
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(fetchLocations))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    let blc = BasicLocationController()
    
    func fetchLocations(){
        blc.getAllLocations { (locations, error) in
            if error != nil{
                self.drawLocationsOnMap(locations!)
            }
        }
            
        }
    
    private func drawLocationsOnMap(location:[BOLocation]){
        for places in location{
            mapView.addAnnotation(places)
        }
    }
}
