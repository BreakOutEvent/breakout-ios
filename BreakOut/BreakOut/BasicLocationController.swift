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
    
    func getAllLocations(onComplete: (locations:Array<MapLocation>?, error:NSError?) -> Void) {
        let url = NSURL(string: PrivateConstants.backendURL)
        //let path = "event/1/location/"
        let sessionManager: AFHTTPSessionManager = AFHTTPSessionManager.init(baseURL: url)
    
        sessionManager.requestSerializer = AFJSONRequestSerializer()
        sessionManager.GET("http://breakout-development.herokuapp.com/event/1/location/", parameters: nil, progress: nil, success: {task, response in
            let response = response as! Array<NSDictionary>
            print(response)
            let locations = self.convertNSDictionaryToMapLocation(response)
            onComplete(locations: locations, error: nil)
            
            }) { task, error in
                print(error)
        }
//        sessionManager.GET(path, parameters: nil, success: {
//            (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
//            let response = response as! Array<NSDictionary>
//            let locations = self.convertNSDictionaryToBOLocation(response)
//            onComplete(locations: locations, error: nil)
//        }) {
//            (task: NSURLSessionDataTask?, error: NSError) -> Void in
//            onComplete(locations: nil, error: error)
//        }
    }
    
    private func convertNSDictionaryToMapLocation(dicts: Array<NSDictionary>) -> Array<MapLocation> {
        return dicts.map({ dict in convertToLocation(dict) }).flatMap({ dict in dict })
        
    }
    
    private func convertToLocation(dict: NSDictionary) -> MapLocation? {
        let longitude = dict.valueForKey("longitude") as! CLLocationDegrees
        let latitude = dict.valueForKey("latitude") as! CLLocationDegrees
        let coordiante = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = MapLocation(coordinate: coordiante, title: dict.valueForKey("team") as? String, subtitle: dict.valueForKey("distance") as? String)
        
        return location
    }
}