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
    let date: Date
    let longitude: Double
    let latitude: Double
    let team: Team?
    let country: String?
    let locality: String?
}

extension Location: Deserializable {
    
    init?(from json: JSON) {
        guard let id = json["id"].int,
            let date = json["date"].date(),
            let latitude = json["latitude"].double,
            let longitude = json["longitude"].double else {
                return nil
        }
        self.init(id: id,
                  date: date,
                  longitude: longitude,
                  latitude: latitude,
                  team: json.team,
                  country: json["locationData"]["COUNTRY"].string,
                  locality: json["locationData"]["LOCALITY"].string ?? json["locationData"]["ADMINISTRATIVE_AREA_LEVEL_3"].string)
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
            "latitude": coordinates.latitude.json,
            "longitude": coordinates.longitude.json,
            "date": Date.now.timeIntervalSince1970.json
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
     Fetch all the locations in an event
     
     - Parameter event: id of the event
     - Parameter api: Break Out backend
     
     - Returns: Promise of the locations
     */
    static func all(for event: Int, using api: BreakOut = .shared) -> Location.Results {
        return getAll(using: api, at: .eventAllLocations, arguments: ["event": event])
    }
    
    /**
     Fetch all the locations in an event by a team
     
     - Parameter team: id of the team
     - Parameter event: id of the event
     - Parameter api: Break Out backend
     
     - Returns: Promise of the locations
     */
    static func all(forTeam team: Int, event: Int, using api: BreakOut = .shared) -> Location.Results {
        return getAll(using: api, at: .eventTeamLocation, arguments: ["event": event, "team": team])
    }
    
}

extension Location {
    
    /// Coordinates of this location
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
