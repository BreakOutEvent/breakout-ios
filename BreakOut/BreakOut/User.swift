//
//  User.swift
//  MapView
//
//  Created by David Symhoven on 01.05.16.
//  Copyright © 2016 David Symhoven. All rights reserved.
//  
//  DUMMY CLASS

import MapKit

class User:NSObject, MKAnnotation {
    // title is optional property in MKAnnotation protocol
    let name:String?
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    
    init(name: String, locationName: String, coordinate: CLLocationCoordinate2D) {

        self.name = name;
        self.title = name;
        self.locationName = locationName
        self.coordinate = coordinate
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
}

