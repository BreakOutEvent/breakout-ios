//
//  BONetworkerTest.swift
//  BreakOut
//
//  Created by Leo Käßner on 29.11.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import Foundation
import AFNetworking
import AFOAuth2Manager

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
        let jsonString: String = "{\"uuid\": \"123\", \"text\": \"tester\"}"
        let jsonData: Data = jsonString.data(using: String.Encoding.utf8)!
        do {
            let newPostObject:NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            let newPost:BOPost = BOPost.mr_import(from: newPostObject)
            print("Text attribute of new Post: "+newPost.text!)
        }catch{
            print(error)
        }
        
        
        
        // The following code is the test for image caching with SDWebImage Framework
        /*let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) -> Void in
            //print("SDWebImageTest: "+self)
            print(image)
        }
        let url = NSURL(string: "https://placehold.it/350x150")
        self.testImageView.sd_setImageWithURL(url, completed: block)*/
        // End of test code
    }
    
    func exampleLogin() {
        let baseURL: URL = URL(string: "http://breakout-development.herokuapp.com/")!
        
        let oAuthManager: AFOAuth2Manager = AFOAuth2Manager.init(baseURL: baseURL, clientID: "breakout_app", secret: "123456789")
        
        oAuthManager.authenticateUsingOAuth(withURLString: "/oauth/token", username: "a@b.c", password: "fdsa", scope: "read write", success: { (credentials) -> Void in
             print("OAuth Code: "+credentials.accessToken)
            }) { (error) -> Void in
                print(error)
        }
    }
}
