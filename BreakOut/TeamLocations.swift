//
//  TeamLocations.swift
//  BreakOut
//
//  Created by Mathias Quintero on 4/8/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

struct TeamLocations {
    let teamName: String
    let locations: [Location]
}

extension TeamLocations: Deserializable {
    
    init?(from json: JSON) {
        guard let teamName = json["name"].string else {
            return nil
        }
        self.init(teamName: teamName, locations: json["locations"].locations)
    }
    
}

extension TeamLocations {
    
    /**
     Fetch all the locations in an event by a team
     
     - Parameter team: id of the team
     - Parameter event: id of the event
     - Parameter api: Break Out backend
     
     - Returns: Promise of the locations
     */
    static func locations(forTeam team: Team, locationsPerTeam perTeam: Int? = nil, using api: BreakOut = .shared) -> TeamLocations.Result {
        return Location.all(forTeam: team.id, event: team.event, locationsPerTeam: perTeam).nested { locations in
            return TeamLocations(teamName: team.name, locations: locations)
        }
    }
    /**
     Fetch all the locations in an event
     
     - Parameter event: id of the event
     - Parameter api: Break Out backend
     
     - Returns: Promise of the locations
     */
    static func all(for event: Int, locationsPerTeam perTeam: Int? = nil, using api: BreakOut = .shared) -> TeamLocations.Results {
        var queries = [String : CustomStringConvertible]()
        queries["perTeam"] = perTeam
        return getAll(using: api, at: .eventAllLocations, arguments: ["event": event], queries: queries)
    }
    
}

extension TeamLocations {
    
    func mapLocations() -> [MapLocation] {
        return locations => { location in
            let distanceString = String(format: "%.3f km", location.distance)
            return MapLocation(coordinate: location.coordinates, title: teamName, subtitle: distanceString, posting: location.postingId)
        }
    }
    
}
