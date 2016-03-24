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
        var printText: String = ""
        if text.containsString("SUCCESSFUL") {
            printText = "✅"
        }
        if text.containsString("WARNING") {
            printText = "⚠️"
        }
        if text.containsString("ERROR") {
            printText = "❗️"
        }
        
        printText += text
        
        
        if FeatureFlagManager.sharedInstance.isActivated(FeatureFlags.showDebuggingToasts){
            JLToast.makeText(printText, duration: JLToastLongDelay).show()
            
            #if DEBUG
                print("BOToast: " + printText + "\r\n")
            #endif
        }
    }

}
