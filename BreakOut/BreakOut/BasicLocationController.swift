//
//  BasicLocationController.swift
//  BreakOut
//
//  Created by David Symhoven on 02.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation

protocol LocationController {
    func getAllLocations(onComplete: (locations: Array<BOLocation>?, error: NSError?) -> Void)
}

class BasicLocationController : LocationController {
    
    func getAllLocations(onComplete: (locations:Array<BOLocation>?, error:NSError?) -> Void) {
        
        let url = NSURL(string: PrivateConstants.backendURL)
        let path = "event/1/location/"
        let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: url)
        requestManager.requestSerializer = AFJSONRequestSerializer()
        
        requestManager.GET(path, parameters: nil, success: {
            (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            let response = response as! Array<NSDictionary>
            let locations = self.convertNSDictionaryToBOLocation(response)
            onComplete(locations: locations, error: nil)
        }) {
            (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
            onComplete(locations: nil, error: error)
        }
    }
    
    private func convertNSDictionaryToBOLocation(dicts: Array<NSDictionary>) -> Array<BOLocation> {
        return dicts.map({ dict in convertToLocation(dict) }).flatMap({ dict in dict })
        
    }
    
    private func convertToLocation(dict: NSDictionary) -> BOLocation? {
        let location = BOLocation()
        if let latitude = dict.objectForKey("latitude") as? NSNumber{
            location.latitude = latitude
        }
        if let longitude = dict.objectForKey("longitude") as? NSNumber{
            location.longitude = longitude
        }
        return location
    }
}