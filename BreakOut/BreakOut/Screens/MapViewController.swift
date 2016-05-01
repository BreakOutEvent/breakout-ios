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
    // > activate delegation from sidebarTableViewController
    
    let initalLocation = CLLocation(latitude: 48.13842, longitude: 11.57917)
    let regionRadius : CLLocationDistance = 5000
    var users = [User]()
    
    
    
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.mapType = .Satellite
            mapView.delegate = self
            createUserArray()
            for name in users{
                mapView.addAnnotation(name)
            }
        }
    }
    
    
    func createUserArray(){
        let David = User(name: "David", locationName: "München", coordinate: CLLocationCoordinate2D(latitude: 48.099656, longitude: 11.531533))
        let Florian = User(name: "Florian", locationName: "Madrid", coordinate: CLLocationCoordinate2D(latitude: 40.416775, longitude: -3.70379))
        users.append(David)
        users.append(Florian)
    }
}
