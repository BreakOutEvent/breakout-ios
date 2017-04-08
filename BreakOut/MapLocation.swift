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
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?){
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
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
    
    static func inPostings(with ids: [Int], using api: BreakOut = .shared) -> MapLocation.Results {
        return api.doObjectsRequest(with: .post, to: .notLoadedPostings, body: ids.json)
    }
    
    static func inPostings(by team: Int, in event: Int, using api: BreakOut = .shared) -> MapLocation.Results {
        /// TODO: Find a way to ease the load without skipping 4 in 5 posts
        return Post.ids(by: team, in: event).onSuccess(call: (Array.including ** 5) >>> (MapLocation.inPostings <** api)).future
    }
    
    func post() -> Post.Result {
        guard let id = posting else {
            return .errored(with: .cannotPerformRequest)
        }
        return Post.posting(with: id)
    }
    
}
