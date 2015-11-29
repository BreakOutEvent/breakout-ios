//
//  BOSynchronizeController.swift
//  BreakOut
//
//  Created by Leo Käßner on 29.11.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//



import Foundation
import ReachabilitySwift

/**
 The BOSynchronizeController communicates with the REST-API and stores the responses in the local Database.
 This will synchronize the online Backend with the local App-Backend.
 */
class BOSynchronizeController: NSObject {
    
    static let sharedInstance = BOSynchronizeController()
    
    var reachability: Reachability?
    var internetReachability: String = "unknown"
    
// MARK: - HELPERS
// MARK: Internet Reachability
    
    /** 
    Checks wether the current internet reachability is known (if not, start the check) and returns the current status.
    
    - returns: String of current reachability status (`unknown`, `wifi`, `cellular`, `not_reachable`)
    
    - author: Leo Käßner
    */
    func internetReachabilityStatus() -> String {
        if internetReachability == "unknown" {
            checkForInternetReachability()
        }
        return internetReachability
    }
    
    /**
     Starts the Internet Reachability check and registers a notification observer, so that the app gets notified if internet reachability changes.
     
     The current reachability status is stored in the 'internetReachability' var and has one of the following values: 'unknown', 'wifi', 'cellular' or 'not_reachable'
     */
    func checkForInternetReachability() {
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        
        reachability!.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    self.internetReachability = "wifi"
                    print("Reachable via WiFi")
                } else {
                    self.internetReachability = "cellular"
                    print("Reachable via Cellular")
                }
            }
        }
        reachability!.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                self.internetReachability = "not_reachable"
                print("Not reachable")
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "reachabilityChanged:",
            name: ReachabilityChangedNotification,
            object: reachability)
        
        do {
            try reachability!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                self.internetReachability = "wifi"
                print("Reachable via WiFi")
            } else {
                self.internetReachability = "cellular"
                print("Reachable via Cellular")
            }
        } else {
            self.internetReachability = "not_reachable"
            print("Not reachable")
        }
    }
    
// MARK: - REST-API Requests
}
