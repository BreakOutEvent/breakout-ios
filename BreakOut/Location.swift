//
//  Location.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import CoreLocation

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
        self.init(id: id, date: date, longitude: longitude, latitude: latitude, team: json.team, country: json["locationData"]["COUNTRY"].string, locality: json["locationData"]["LOCALITY"].string)
    }
    
}

extension Location {
    
    static func all(for event: Int, using api: BreakOut = .shared) -> Location.Results {
        return getAll(using: api, at: .eventAllLocations, arguments: ["event": event])
    }
    
    static func all(forTeam team: Int, event: Int, using api: BreakOut = .shared) -> Location.Results {
        return getAll(using: api, at: .eventTeamLocation, arguments: ["event": event, "team": team])
    }
    
}

extension Location {
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}