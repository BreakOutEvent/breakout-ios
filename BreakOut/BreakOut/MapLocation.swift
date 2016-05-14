//
//  MapLocation.swift
//  BreakOut
//
//  Created by David Symhoven on 14.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation
import MapKit

class MapLocation: NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?){
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
    
    
}
