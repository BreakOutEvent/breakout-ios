//
//  FeatureFlagManager.swift
//  BreakOut
//
//  Created by Leo Käßner on 20.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Pantry

import JLToast

// Tracking
import Flurry_iOS_SDK

class FeatureFlagManager: NSObject {
    static let sharedInstance = FeatureFlagManager()
    
    func isActivated(featureFlag: String) -> Bool {
        if let retrieveFeatureFlag: Bool = Pantry.unpack(featureFlag) {
            return retrieveFeatureFlag
        }
        
        // If no stored value for the feature flag can be found, the standard return is 'true'
        return true
    }
    
    func downloadCurrentFeatureFlagSetup() {
        
        // New request manager with our backend URL as baseURL
        let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL(string: FeatureFlags.backendURL))
        
        // Sets the serialization of parameters to JSON format
        requestManager.requestSerializer = AFJSONRequestSerializer()
        
        //Tracking
        Flurry.logEvent("/featureFlags/download", timed: true)
        
        requestManager.GET("featureFlags/", parameters: nil, success: {
            (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            // GET Request was successful
            print("DownloadCurrentFeatureFlagSetup Response: ")
            print(response)
            BOToast.log("DownloadCurrentFeatureFlagSetup was successful")
            
            // response is an Array
            for featureFlagConfig: NSDictionary in response as! Array {
                let key: String = featureFlagConfig.valueForKey("description") as! String
                Pantry.pack(featureFlagConfig.valueForKey("enabled") as! Bool, key: key)
            }
            
            Flurry.endTimedEvent("/featureFlags/download", withParameters: ["successful":true])
            
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                //TODO: Handle the error
                print("ERROR: While DownloadCurrentFeatureFlagSetup")
                print(error)
                BOToast.log("Error while DownloadCurrentFeatureFlagSetup", level: .Error)
                
                //Tracking
                Flurry.endTimedEvent("/featureFlags/download", withParameters: ["successful":false])
        }
        
        Pantry.pack(true, key: "featureFlag")
    }
}

struct FeatureFlags {
    
    static let backendURL = "http://breakout-featureflags.herokuapp.com/"
    
    static let showDebuggingToasts: String = "show_debuggingToasts"
}
