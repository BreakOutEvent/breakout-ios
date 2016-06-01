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
        
        if featureFlag == FeatureFlags.useDevelopBackend {
            return false
        }
        
        // If no stored value for the feature flag can be found, the standard return is 'true'
        return true
    }
    
    func downloadCurrentFeatureFlagSetup() {
        
        BONetworkManager.doJSONRequestGET(.FeatureFlags, arguments: [], parameters: nil, auth: false, success: { (response) in
            for featureFlagConfig: NSDictionary in response as! Array {
                let key: String = featureFlagConfig.valueForKey("description") as! String
                Pantry.pack(featureFlagConfig.valueForKey("enabled") as! Bool, key: key)
            }
            
            Flurry.endTimedEvent("/featureFlags/download", withParameters: ["successful":true])
        }) { (_,_) in
            //Tracking
            Flurry.endTimedEvent("/featureFlags/download", withParameters: ["successful":false])
        }
        
        Pantry.pack(true, key: "featureFlag")
    }
}

struct FeatureFlags {
    
    static let backendURL = "http://breakout-featureflags.herokuapp.com/"
    
    static let showDebuggingToasts: String = "show_debuggingToasts"
    static let useDevelopBackend: String = "use_developBackend"
}
