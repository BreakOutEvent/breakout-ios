//
//  FeatureFlagManager.swift
//  BreakOut
//
//  Created by Leo Käßner on 20.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Pantry

import Toaster
import Sweeft

// Tracking

struct Feature {
    let key: String
    let enabled: Bool
    
    func pack() {
        Pantry.pack(enabled, key: key)
    }
}

extension Feature: Deserializable {
    
    public init?(from json: JSON) {
        guard let key = json["description"].string,
            let enabled = json["enabled"].bool else {
                
            return nil
        }
        self.init(key: key, enabled: enabled)
    }
    
}

extension Feature {
    
    static func all(using api: BreakOut = .shared) -> Feature.Results {
        return getAll(using: api, at: .featureFlags)
    }
    
}

class FeatureFlagManager: NSObject {
    static let shared = FeatureFlagManager()
    
    func isActivated(_ featureFlag: String) -> Bool {
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
        Feature.all().onSuccess(in: .main) { features in
            features => Feature.pack
            Flurry.endTimedEvent("/featureFlags/download", withParameters: ["successful": true])
        }
        .onError(in: .main) { error in
            Flurry.endTimedEvent("/featureFlags/download", withParameters: ["successful": false])
        }
        Pantry.pack(true, key: "featureFlag")
    }
}

struct FeatureFlags {
    
    static let backendURL = "http://breakout-featureflags.herokuapp.com/"
    
    static let showDebuggingToasts: String = "show_debuggingToasts"
    static let useDevelopBackend: String = "use_developBackend"
}
