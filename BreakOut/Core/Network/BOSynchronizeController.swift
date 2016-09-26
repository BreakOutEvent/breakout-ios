//
//  BOSynchronizeController.swift
//  BreakOut
//
//  Created by Leo Käßner on 29.11.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//



import Foundation
import ReachabilitySwift

// Database
import MagicalRecord

// Tracking
import Flurry_iOS_SDK
import Crashlytics

/**
 The BOSynchronizeController communicates with the REST-API and stores the responses in the local Database.
 This will synchronize the online Backend with the local App-Backend.
 */
class BOSynchronizeController: NSObject {
    
    static let shared = BOSynchronizeController()
    
    static var images: BOImageSyncManager {
        get {
            return shared.getManager(name: "images")
        }
    }
    
    static var posts: BOPostSyncManager {
        get {
            return shared.getManager(name: "posts")
        }
    }
    
    static var teams: BOTeamSyncManager {
        get {
            return shared.getManager(name: "teams")
        }
    }
    
    static var comments: BOCommentSyncManager {
        get {
            return shared.getManager(name: "comments")
        }
    }
    
    let managers: [String:BOSyncManager]
    
    override init() {
        managers = ["posts": BOPostSyncManager(),
                    "images": BOImageSyncManager(),
                    "teams": BOTeamSyncManager(),
                    "comments": BOCommentSyncManager(),
                    "locations": BOLocationSyncManager()
        ]
    }
    
    func getManager<T: BOSyncManager>(name: String) -> T  {
        return managers[name] as? T ?? T()
    }
    
    /**
     Makes a total database synchronization of all tables. It starts all Requests for each Database table and stores all repsones. This should only be used at the first start of the app, when no data is in it. Also be carfeully with loading too much data over cellular
    */
    func totalDatabaseSynchronization() {
        downloadAllMissing()
        uploadAllMissing()
    }
    
    func downloadAllMissing() {
        for (_,manager) in managers {
            manager.dowloadMisisng()
        }
    }
    
    func uploadAllMissing() {
        for (_,manager) in managers {
            manager.uploadMissing()
        }
    }
    
    func triggerUpload() {
        if isReachable {
            uploadAllMissing()
        }
    }

    
// #############################################################################################
// MARK: - HELPERS
// MARK: Internet Reachability
    
    private var reachability: Reachability?
    private var internetReachability: String = "unknown"
    
    var isReachable: Bool {
        get {
            return self.internetReachability == "wifi" || self.internetReachability == "cellular"
        }
    }
    
    var hasWifi: Bool {
        get {
            return self.internetReachability == "wifi"
        }
    }
    
    /** 
    Checks wether the current internet reachability is known (if not, start the check) and returns the current status.
    
    - returns: String of current reachability status (`unknown`, `wifi`, `cellular`, `not_reachable`)
    
    - author: Leo Käßner
    */
    var internetStatus: String {
        get {
            if internetReachability == "unknown" {
                checkForInternetReachability()
            }
            return internetReachability
        }
    }
    
    /**
     Starts the Internet Reachability check and registers a notification observer, so that the app gets notified if internet reachability changes.
     
     The current reachability status is stored in the 'internetReachability' var and has one of the following values: 'unknown', 'wifi', 'cellular' or 'not_reachable'
     */
    func checkForInternetReachability() {
        
        guard let reachability = Reachability() else {
            print("Unable to create Reachability")
            return
        }
        
        self.reachability = reachability
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    self.internetReachability = "wifi"
                    
                    self.uploadAllMissing()
                    
                    print("Reachable via WiFi")
                    Answers.logCustomEvent(withName: "/reachability", customAttributes: ["Reachable via":"wifi"])
                } else {
                    self.internetReachability = "cellular"
                    print("Reachable via Cellular")
                    Answers.logCustomEvent(withName: "/reachability", customAttributes: ["Reachable via":"cellular"])
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                self.internetReachability = "not_reachable"
                print("Not reachable")
                Answers.logCustomEvent(withName: "/reachability", customAttributes: ["Reachable via":"Not reachable"])
            }
        }
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(BOSynchronizeController.reachabilityChanged(_:)),
            name: ReachabilityChangedNotification,
            object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func reachabilityChanged(_ note: Notification) {
        
        let reachability = note.object as? Reachability
        
        if reachability?.isReachable ?? false {
            if reachability?.isReachableViaWiFi ?? false {
                self.internetReachability = "wifi"
                print("Reachable via WiFi")
                Answers.logCustomEvent(withName: "/reachability", customAttributes: ["Reachable via":"wifi"])
                
                totalDatabaseSynchronization()
            } else {
                self.internetReachability = "cellular"
                print("Reachable via Cellular")
                Answers.logCustomEvent(withName: "/reachability", customAttributes: ["Reachable via":"cellular"])
            }
        } else {
            self.internetReachability = "not_reachable"
            print("Not reachable")
            Answers.logCustomEvent(withName: "/reachability", customAttributes: ["Reachable via":"Not reachable"])
        }
    }
    
    func downloadIdsOfAllEvents() {
        BONetworkManager.doJSONRequestGET(.Event, arguments: [], parameters: nil, auth: false, success: { (response) in
            for newEvent: NSDictionary in response as! Array {
                
                let defaults = UserDefaults.standard
                defaults.set(newEvent.value(forKey: "date")as! Int, forKey: "eventStartTimestamp")
                defaults.synchronize()
//                
//                self.downloadAllTeamsForEvent(newEvent.value(forKey: "id")as! Int)
//                self.downloadAllLocationsForEvent(newEvent.value(forKey: "id")as! Int)
            }
        }) { (error, response) in
        }
    }

    
}
