//
//  BONetworkerTest.swift
//  BreakOut
//
//  Created by Leo Käßner on 29.11.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import Foundation
import AFNetworking

class BONetworkerTest: NSObject {
    
    /*func retrieveAllPostsFromServer() {

        let manager = AFHTTPRequestOperationManager()
        manager.GET("http://api.androidhive.info/json/movies.json", parameters: nil, success: { (operation, responseObject) -> Void in
            let jsonArrays = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSArray
            var arrayofDesiereValue : [String] = []
            for value  in jsonArrays {
                if let value = value as? NSDictionary {
                    arrayofDesieredValue.append(value["desideredkey"] as! String)
                }
            }
        }, failure: nil)

    }*/
    
    /**
    Sends an API request to 4sq for venues around a given location with an optional text search
    
    :param: location    A CLLocation for the user's current location
    :param: query       An optional search query
    :param: completion  A closure which is called with venues, an array of FoursquareVenue objects
    
    :returns: No return value
    */
    func postObjectFromJSON() {
        let jsonString: String = "{\"uuid\": \"123\", \"name\": \"tester\"}"
        let jsonData: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        do {
            let newPostObject:NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            let newPost:BOPost = BOPost.MR_importFromObject(newPostObject)
            print("Name attribute of new Post: "+newPost.name!)
        }catch{
            print(error)
        }
    }
}