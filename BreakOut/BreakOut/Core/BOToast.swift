//
//  BOToast.swift
//  BreakOut
//
//  Created by Leo Käßner on 20.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

import JLToast

class BOToast {
    
    init(text: String) {
        if FeatureFlagManager.sharedInstance.isActivated(FeatureFlags.showDebuggingToasts){
            JLToast.makeText(text, duration: JLToastLongDelay).show()
        }
    }

}
