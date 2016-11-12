//
//  MapLocation.swift
//  BreakOut
//
//  Created by David Symhoven on 14.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation
import MapKit

/**
 simple class conforming to MKAnnotation in order for instances of MapLocation to be displayed on the MapView.
 
 coordiante is required
 
 title is optional
 
 subtitle is optional
 
 TODO: add image to Annotation and maybe other accessory views
 
*/
class MapLocation: NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var posting: Posting?
    
//    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?){
//        self.coordinate = coordinate
//        self.title = title
//        self.subtitle = subtitle
//        super.init()
//    }
    
    init(latitude:CLLocationDegrees, longitude:CLLocationDegrees, title: String?){
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = title
        super.init()
    }
    
    
}
