//
//  Location.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import CoreLocation

/// Location of a Team
struct Location {
    let id: Int
    let postingId: Int?
    let date: Date
    let longitude: Double
    let latitude: Double
    let team: Team?
    let country: String?
    let locality: String?
    let distance: Double
}

extension Location: Deserializable {
    
    init?(from json: JSON) {
        guard let id = json["id"].int,
            let date = json["date"].date(),
            let latitude = json["latitude"].double,
            let longitude = json["longitude"].double,
            let distance = json["distance"].double else {
                return nil
        }
        self.init(id: id,
                  postingId: json["postingId"].int,
                  date: date,
                  longitude: longitude,
                  latitude: latitude,
                  team: json.team,
                  country: json["locationData"]["COUNTRY"].string,
                  locality: json["locationData"]["LOCALITY"].string ?? json["locationData"]["ADMINISTRATIVE_AREA_LEVEL_3"].string,
                  distance: distance)
    }
    
}

extension Location {
    
    /**
     Update the backend on your location
     
     - Parameter coordinates: Coordinates of the user
     - Parameter event: id of the event
     - Parameter team: id of the team
     - Parameter api: Break Out backend
     
     - Returns: Promise of the generated Location
     */
    @discardableResult static func update(coordinates: CLLocationCoordinate2D,
                                          event: Int,
                                          team: Int,
                                          using api: BreakOut = .shared) -> Location.Result {
        let body: JSON = [
            "latitude": coordinates.latitude,
            "longitude": coordinates.longitude,
            "date": Date.now.timeIntervalSince1970
        ]
        return api.doObjectRequest(with: .post,
                                   to: .eventTeamLocation,
                                   arguments: ["event": event, "team": team],
                                   auth: api.auth,
                                   body: body,
                                   acceptableStatusCodes: [200, 201])
    }
    
}

extension Location {
    
    /**
     Fetch all the locations in an event by a team
     
     - Parameter team: id of the team
     - Parameter event: id of the event
     - Parameter api: Break Out backend
     
     - Returns: Promise of the locations
     */
    static func all(forTeam team: Int, event: Int, locationsPerTeam perTeam: Int? = nil, using api: BreakOut = .shared) -> Location.Results {
        var queries = [String : CustomStringConvertible]()
        queries["perTeam"] = perTeam
        return getAll(using: api, at: .eventTeamLocation, arguments: ["event": event, "team": team], queries: queries)
    }
    
}

extension Location {
    
    /// Coordinates of this location
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
