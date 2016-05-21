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
    func getAllLocations(onComplete: (locations: Array<MapLocation>?, error: NSError?) -> Void)
}

class BasicLocationController : LocationController {
    /**
     invokes request to server via AFHTTPSessionManager and AFJSONRequestSerializer and casts response to NSDictionary.
     - parameter onComplete: completion handler
     - returns: Array of locations as MapLocation conforming to MKAnnotation protocol
     */
    func getAllLocations(onComplete: (locations:Array<MapLocation>?, error:NSError?) -> Void) {
        let url = NSURL(string: PrivateConstants().backendURL())
        //let path = "event/1/location/"
        let sessionManager: AFHTTPSessionManager = AFHTTPSessionManager.init(baseURL: url)
    
        sessionManager.requestSerializer = AFJSONRequestSerializer()
        sessionManager.GET("http://breakout-development.herokuapp.com/event/1/location/", parameters: nil, progress: nil, success: {task, response in
            let response = response as! Array<NSDictionary>
            //print(response)
            let locations = self.convertNSDictionaryToMapLocation(response)
            onComplete(locations: locations, error: nil)
            
            }) { task, error in
                print(error)
        }
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