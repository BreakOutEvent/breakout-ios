//
//  BOToast.swift
//  BreakOut
//
//  Created by Leo Käßner on 20.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

import Toaster

class BOToast {
    
    enum Level {
        case success, warning, error
    }
    
    class func log(_ message: String, level: Level = Level.success) {
        
        let toBePrinted: String = {
            switch level {
            case .success: return "✅ \(message)"
            case .warning: return "⚠️ \(message)"
            case .error: return "❗️ \(message)"
            }
        }()
        
        if FeatureFlagManager.sharedInstance.isActivated(FeatureFlags.showDebuggingToasts) {
//            JLToast.makeText(toBePrinted, duration: JLToastLongDelay).show()
//            #if DEBUG
//                print("BOToast: \(toBePrinted)")
//            #endif
        }
    }
}
