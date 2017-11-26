//
//  LocationUploadQueue.swift
//  BreakOut
//
//  Created by Mathias Quintero on 5/15/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import CoreLocation

class LocationUploadQueue {
    
    static var shared = LocationUploadQueue(directory: "Locations")
    
    let directory: String
    
    lazy var cache: FileCache = {
        return FileCache(directory: self.directory)
    }()
        
    var locations: [JSON] {
        get {
            guard let cached = cache.get(with: "queue", maxTime: .forever),
                let json = JSON(data: cached),
                let locations = json.array else {
                    
                return []
            }
            return locations
        }
        set {
            guard !locations.isEmpty, let data = JSON.array(locations).data else {
                return cache.delete(at: "queue")
            }
            cache.store(data, with: "queue")
        }
    }
    
    init(directory: String) {
        self.directory = directory
    }
    
    func process(event: Int = CurrentUser.shared.currentEventId(),
                 team: Int = CurrentUser.shared.currentTeamId(),
                 using api: BreakOut = .shared) {
        
        guard let location = locations.first else {
            return
        }
        api.doJSONRequest(with: .post,
                          to: .eventTeamLocation,
                          arguments: ["event": event, "team": team],
                          auth: api.auth,
                          body: location,
                          acceptableStatusCodes: [200, 201]).onSuccess(in: .main) { json in
                            
            self.locations.remove(at: 0)
            self.process(event: event, team: team, using: api)
        }
    }
    
    func add(coordinates: CLLocationCoordinate2D) {
        let location: JSON = [
            "latitude": coordinates.latitude,
            "longitude": coordinates.longitude,
            "date": Date.now.timeIntervalSince1970
        ]
        locations.append(location)
    }
    
    
}
