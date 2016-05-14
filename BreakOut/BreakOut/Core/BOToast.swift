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
    
    enum Level {
        case Success, Warning, Error
    }
    
//    class func log(message: String, level: Level = Level.Success) {
//        
//        let toBePrinted: String = {
//            switch level {
//            case .Success: return "✅ \(message)"
//            case .Warning: return "⚠️ \(message)"
//            case .Error: return "❗️ \(message)"
//            }
//        }()
//        
//        if FeatureFlagManager.sharedInstance.isActivated(FeatureFlags.showDebuggingToasts) {
//            JLToast.makeText(toBePrinted, duration: JLToastLongDelay).show()
//            #if DEBUG
//                print("BOToast: \(toBePrinted)")
//            #endif
//        }
//    }
}
