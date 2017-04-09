//
//  MapLocation.swift
//  BreakOut
//
//  Created by David Symhoven on 14.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation
import Sweeft
import MapKit

/**
 simple class conforming to MKAnnotation in order for instances of MapLocation to be displayed on the MapView.
 
 coordiante is required
 
 title is optional
 
 subtitle is optional
 
 TODO: add image to Annotation and maybe other accessory views
 
*/
final class MapLocation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var posting: Int?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, posting: Int? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.posting = posting
        super.init()
    }
    
    
}

extension MapLocation: Deserializable {
    
    public convenience init?(from json: JSON) {
        guard let location = json["postingLocation"].location, let id = json["id"].int else {
            return nil
        }
        self.init(coordinate: location.coordinates, title: json["user"]["participant"].team?.name, subtitle: json["date"].date()?.toString())
        posting = id
    }
    
}

extension MapLocation {
    
    func post() -> Post.Result {
        guard let id = posting else {
            return .errored(with: .cannotPerformRequest)
        }
        return Post.posting(with: id)
    }
    
}
