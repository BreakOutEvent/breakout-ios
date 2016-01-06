//
//  BOSynchronizeController.swift
//  BreakOut
//
//  Created by Leo Käßner on 29.11.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//



import Foundation
import ReachabilitySwift

// Tracking
import Flurry_iOS_SDK

/**
 The BOSynchronizeController communicates with the REST-API and stores the responses in the local Database.
 This will synchronize the online Backend with the local App-Backend.
 */
class BOSynchronizeController: NSObject {
    
    static let sharedInstance = BOSynchronizeController()
    
    /**
     Makes a total database synchronization of all tables. It starts all Requests for each Database table and stores all repsones. This should only be used at the first start of the app, when no data is in it. Also be carfeully with loading too much data over cellular
    */
    func totalDatabaseSynchronization() {
        self.loadTotalTeamList();
        // ... and all the other methods.
    }

    
// #############################################################################################
// MARK: - HELPERS
// MARK: Internet Reachability
    
    var reachability: Reachability?
    var internetReachability: String = "unknown"
    
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
    
    
// #############################################################################################
// MARK: - REST-API Requests
    
// MARK: Team List
    /**
     Get total list of all teams and store response in Database.
    */
    func loadTotalTeamList() {
        
    }
    
    /**
     Get only updates of the team list till specified date and store response in Database.
    */
    func loadUpdatesOfTeamList(date: NSDate) {
        
    }
    
    /**
     calculates the last update of the team list and loads new team list updates since then. It uses the `loadUpdatesOfTeamList` Function.
    */
    func loadUpdatesOfTeamListSinceLastUpdate() {
        
    }
    
// MARK: Posts List    
    // Similar to functions above ;)
    
// MARK: Likes & Comments
    // Similar to functions above ;)

    
    func testPostUploads() {
        let newPost: BOPost = BOPost.MR_createEntity()
        
        newPost.flagNeedsUpload = true
        newPost.name = "test post"
        
        self.tryUploadAll()
    }
    

// MARK: - Uploads
    
    func tryUploadAll() {
        self.tryUploadPosts()
        /*self.tryUploadLikes()
        self.tryUploadComments()
        self.tryUploadLocations()
        self.tryUploadImages()
        self.tryUploadChatMessanges()*/
    }
    
// MARK: Upload Posts
    
    func tryUploadPosts() {
        // Retrieve Array of all posts which are flagged as offline with need to upload
        let arrayOfPostsToUpload: Array = BOPost.MR_findByAttribute("flagNeedsUpload", withValue: true) as! Array<BOPost>
        
        // Tracking
        Flurry.logEvent("/posting/upload/start", withParameters: ["Number of Posts": arrayOfPostsToUpload.count])
        
        // Start upload process for all offline posts (TODO: Asynchronous)
        for postToUpload: BOPost in arrayOfPostsToUpload {
            // Start upload function for each BOPost
            postToUpload.upload()
        }
    }

}
