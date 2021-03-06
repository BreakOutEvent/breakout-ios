//
//  BasicLocationController.swift
//  BreakOut
//
//  Created by David Symhoven on 02.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation
import Sweeft
import MapKit

protocol LocationController {
    func getAllLocationsForTeams(_ onComplete: (_ locationsForTeams: [[MapLocation]]?, _ error: NSError?) -> Void)
}

class BasicLocationController : LocationController {
    /**
     invokes request to server via AFHTTPSessionManager and AFJSONRequestSerializer and casts response to NSDictionary.
     - parameter onComplete: completion handler
     - returns: Array of locations as MapLocation conforming to MKAnnotation protocol
     */
    func getAllLocationsForTeams(_ onComplete: (_ locationsForTeams:[[MapLocation]]?, _ error:NSError?) -> Void) {
        let locations = self.convertBOLocationsToMapLocation()
        onComplete(locations, nil)
        
        /*let url = NSURL(string: PrivateConstants().backendURL())
        //let path = "event/1/location/"
        let sessionManager: AFHTTPSessionManager = AFHTTPSessionManager.init(baseURL: url)
    
        sessionManager.requestSerializer = AFJSONRequestSerializer()
        sessionManager.GET("http://breakout-development.herokuapp.com/event/1/location/", parameters: nil, progress: nil, success: {task, response in
            let response = response as! Array<NSDictionary>
            print(response)
            //let locations = self.convertNSDictionaryToMapLocation(response)
            let locations = self.convertBOLocationsToMapLocation()
            onComplete(locationsForTeams: locations, error: nil)
            
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
    fileprivate func convertNSDictionaryToMapLocation(_ dicts: Array<NSDictionary>) -> Array<MapLocation> {
        return dicts.map({ dict in extractLocation(dict) }).flatMap({ dict in dict })
        
    }
    
    fileprivate func convertBOLocationsToMapLocation() -> [[MapLocation]] {
        
        var locationArraysForTeams : [[MapLocation]] = []
        var mapLocationArrayForTeamId: [MapLocation] = []
//        let teamArray: [BOTeam] = BOTeam.all
//        
//        for team: BOTeam in teamArray {
//            let teamId = team.uuid
//            if let boLocationArrayForTeamId: [BOLocation] = BOLocation.mr_find(byAttribute: "teamId", withValue: teamId, andOrderBy: "timestamp", ascending: false) as? [BOLocation] {
//                
//                
//                for locationObject:BOLocation in boLocationArrayForTeamId{
//                    if locationObject.latitude.int32Value != 0 && locationObject.longitude.int32Value != 0 {
//                        let location = MapLocation(coordinate: CLLocationCoordinate2DMake(locationObject.latitude.doubleValue, locationObject.longitude.doubleValue), title: locationObject.teamName, subtitle: locationObject.timestamp.toString())
//                        mapLocationArrayForTeamId.append(location)
//                    }
//                }
//                if mapLocationArrayForTeamId.count > 0{
//                    locationArraysForTeams.append(mapLocationArrayForTeamId)
//                    mapLocationArrayForTeamId.removeAll()
//                }
//                
//                
//            }
//        }
        
        return locationArraysForTeams
    }
    
    
    fileprivate func convertBOPostingToMapLocation() -> [MapLocation] {
        return []
//        return BOPost.all.map { (post: BOPost) in
//            return MapLocation(coordinate: CLLocationCoordinate2DMake(post.latitude, post.longitude),
//                               title: post.team?.name,
//                               subtitle: post.text)
//        }
    }
    

    /**
     extracts location information from each NSDictionary. 
     Response dictionary contais all kind of information. Values of interest are just longitude and latitude
     - parameter dict: one NSDictionary from response
     - returns: location as MapLocation
     */
    fileprivate func extractLocation(_ dict: NSDictionary) -> MapLocation? {
        let longitude = dict.value(forKey: "longitude") as! CLLocationDegrees
        let latitude = dict.value(forKey: "latitude") as! CLLocationDegrees
        let title = dict.value(forKey: "team") as! String
        let subtitle = dict.value(forKey: "distance") as! NSNumber
        let coordiante = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = MapLocation(coordinate: coordiante, title: title, subtitle: "distance: \(subtitle)")

        return location
    }
}
