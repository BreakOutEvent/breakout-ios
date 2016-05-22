//
//  BasicLocationController.swift
//  BreakOut
//
//  Created by David Symhoven on 02.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation
import MapKit

protocol LocationController {
    func getAllLocationsForTeams(onComplete: (locationsForTeams: [[MapLocation]]?, error: NSError?) -> Void)
}

class BasicLocationController : LocationController {
    /**
     invokes request to server via AFHTTPSessionManager and AFJSONRequestSerializer and casts response to NSDictionary.
     - parameter onComplete: completion handler
     - returns: Array of locations as MapLocation conforming to MKAnnotation protocol
     */
    func getAllLocationsForTeams(onComplete: (locationsForTeams:[[MapLocation]]?, error:NSError?) -> Void) {
        let locations = self.convertBOLocationsToMapLocation()
        onComplete(locationsForTeams: locations, error: nil)
        
        /*let url = NSURL(string: PrivateConstants().backendURL())
        //let path = "event/1/location/"
        let sessionManager: AFHTTPSessionManager = AFHTTPSessionManager.init(baseURL: url)
    
        sessionManager.requestSerializer = AFJSONRequestSerializer()
        sessionManager.GET("http://breakout-development.herokuapp.com/event/1/location/", parameters: nil, progress: nil, success: {task, response in
            let response = response as! Array<NSDictionary>
            print(response)
            //let locations = self.convertNSDictionaryToMapLocation(response)
            let locations = self.convertBOLocationsToMapLocation()
            onComplete(locations: locations, error: nil)
            
            }) { task, error in
                print(error)
        }*/
    }
    
    /**
     converts response of server (JSON Objects as NSDictionaries) to MapLocations in order for them to be displayed on the map.
     Uses map-function on the dictionaries to extract longitude and latitude
     - parameter dict: response from server as NSDictionary
     - returns: Array of locations as MapLocation which can be displayed on map
     */
    private func convertNSDictionaryToMapLocation(dicts: Array<NSDictionary>) -> Array<MapLocation> {
        return dicts.map({ dict in extractLocation(dict) }).flatMap({ dict in dict })
        
    }
    
    private func convertBOLocationsToMapLocation() -> [[MapLocation]] {
        
        var locationArraysForTeams : [[MapLocation]] = []
        var mapLocationArrayForTeamId: [MapLocation] = []
        let teamArray: [BOTeam] = BOTeam.MR_findAll() as! [BOTeam]
        
        for team: BOTeam in teamArray {
            let teamId = team.uuid
            print(teamId)
            if let boLocationArrayForTeamId: [BOLocation] = BOLocation.MR_findByAttribute("teamId", withValue: teamId, andOrderBy: "timestamp", ascending: false) as? [BOLocation] {
                
                
                for locationObject:BOLocation in boLocationArrayForTeamId{
                    let location = MapLocation(coordinate: CLLocationCoordinate2DMake(locationObject.latitude.doubleValue, locationObject.longitude.doubleValue), title: teamId.description, subtitle: "distance")
                    print(" === function ===")
                    print(location.coordinate)
                    mapLocationArrayForTeamId.append(location)

                }
                if mapLocationArrayForTeamId.count > 0{
                    locationArraysForTeams.append(mapLocationArrayForTeamId)
                    mapLocationArrayForTeamId.removeAll()
                }
                
                
            }
        }
        
        return locationArraysForTeams
    }
    
    
    private func convertBOPostingToMapLocation() -> Array<MapLocation> {
        var mutableArray: Array<MapLocation> = Array()
        let postingArray = BOPost.MR_findAll() as! [BOPost]
        
        for postingObject:BOPost in postingArray {
            let location = MapLocation(coordinate: CLLocationCoordinate2DMake(postingObject.latitude.doubleValue, postingObject.longitude.doubleValue), title: postingObject.team?.name, subtitle: postingObject.text)
            mutableArray.append(location)
        }
        
        return mutableArray
    }
    

    /**
     extracts location information from each NSDictionary. 
     Response dictionary contais all kind of information. Values of interest are just longitude and latitude
     - parameter dict: one NSDictionary from response
     - returns: location as MapLocation
     */
    private func extractLocation(dict: NSDictionary) -> MapLocation? {
        let longitude = dict.valueForKey("longitude") as! CLLocationDegrees
        let latitude = dict.valueForKey("latitude") as! CLLocationDegrees
        let title = dict.valueForKey("team") as! String
        let subtitle = dict.valueForKey("distance") as! NSNumber
        let coordiante = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = MapLocation(coordinate: coordiante, title: title, subtitle: "distance: \(subtitle)")

        return location
    }
}