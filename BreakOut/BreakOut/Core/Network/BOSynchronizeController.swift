//
//  BOSynchronizeController.swift
//  BreakOut
//
//  Created by Leo Käßner on 29.11.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//



import Foundation
import ReachabilitySwift

import Pantry

// Tracking
import Flurry_iOS_SDK

/**
 The BOSynchronizeController communicates with the REST-API and stores the responses in the local Database.
 This will synchronize the online Backend with the local App-Backend.
 */
class BOSynchronizeController: NSObject {
    
    var arrayOfNotYetDownloadedPostings: [Int] = [Int]()
    
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
        newPost.text = "test post"
        
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
    
    
// MARK: - Postings
// MARK: Download Postings
    
    func downloadArrayOfNewPostingIDsSinceLastKnownPostingID() {
        if let lastKnownPostingID: Int = Pantry.unpack("lastKnownPostingID") {
            self.downloadArrayOfNewPostingIDsSince(lastKnownPostingID)
        }else{
            self.downloadArrayOfNewPostingIDsSince(0)
        }
    }
    
    func downloadArrayOfNewPostingIDsSince(lastID: Int) {
        // New request manager with our backend URL as baseURL
        let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL(string: PrivateConstants.backendURL))
        
        // Sets the serialization of parameters to JSON format
        requestManager.requestSerializer = AFJSONRequestSerializer()
        
        requestManager.GET(String(format: "posting/get/since/%i/", lastID), parameters: nil, success: {
            (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            // GET Request was successful 
            print("DownloadArrayOfNewPostingIDsSince Response: ")
            print(response)
            
            self.addIDsToNotYetLoadedPostingsIDs(response as! [Int])
            
            self.downloadNotYetLoadedPostings()
            
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                //TODO: Handle the error
                print("ERROR: While DownloadArrayOfNewPostingIDsSince")
                print(error)
        }
    }
    
    func downloadNotYetLoadedPostings() {
        // Restore the Array with all postingIDs, which aren't loaded yet, from Pantry
        if let restoredArrayOfNotYetDownloadedPostings: [Int] = Pantry.unpack("notYetLoadedPostings")! {
            self.arrayOfNotYetDownloadedPostings = restoredArrayOfNotYetDownloadedPostings
            
            print("IDs of not yet loaded Postings")
            print(self.arrayOfNotYetDownloadedPostings.count)
            
            // New request manager with our backend URL as baseURL
            let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL(string: PrivateConstants.backendURL))
            
            // Sets the serialization of parameters to JSON format
            requestManager.requestSerializer = AFJSONRequestSerializer()
            
            var arrayOfIDsToLoad: [Int] = [Int]()
            var count:Int = 50
            for postID in self.arrayOfNotYetDownloadedPostings {
                arrayOfIDsToLoad += [postID]
                count--
                if count <= 0 {
                    break
                }
            }
            
            
            // Send POST request to backend to receive all not yet loaded postings
            requestManager.POST("posting/get/ids", parameters: arrayOfIDsToLoad,
                success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                    print("DownloadNotYetLoadedPostings Response: ")
                    print(response)
                    // response is an Array of Posting Objects
                    for newPosting: NSDictionary in response as! Array {
                        let newPost: BOPost = BOPost.createWithDictionary(newPosting)
                        newPost.printToLog()
                    }
                    
                    self.removeIDsFromNotYetLoadedPostingsIDs(arrayOfIDsToLoad)
                    
                    // Tracking
                    //Flurry.logEvent("/posting/upload/completed_successful")
                })
                { (operation: AFHTTPRequestOperation?, error:NSError) -> Void in
                    print("ERROR: While DownloadNotYetLoadedPostings")
                    print(error)
                    
                    // TODO: Show detailed errors to the user
                    
                    // Tracking
                    //Flurry.logEvent("/posting/upload/completed_error")
            }
        }
    }
    
    func downloadAllPostings() {
        
        //TESTING
        if let restoredArrayOfNotYetDownloadedPostings: [Int] = Pantry.unpack("notYetLoadedPostings")! {
            self.arrayOfNotYetDownloadedPostings = restoredArrayOfNotYetDownloadedPostings
            self.arrayOfNotYetDownloadedPostings = self.arrayOfNotYetDownloadedPostings + [3,4,5]
            Pantry.pack(self.arrayOfNotYetDownloadedPostings, key: "notYetLoadedPostings")
        }else {
            Pantry.pack([0], key: "notYetLoadedPostings")
        }
        
        // New request manager with our backend URL as baseURL
        let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL(string: PrivateConstants.backendURL))
        
        // Sets the serialization of parameters to JSON format
        requestManager.requestSerializer = AFJSONRequestSerializer()
        
        /*requestManager.GET("post/", parameters: nil, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                //TODO: handle successful retrival of all posts
            #if DEBUG
                print("----------------------------------------------")
                print("Download all postings Response: ")
                print(response)
                print("----------------------------------------------")
            #endif
            
            let arrayOfPosts: NSArray = response.valueForKey("posts")
            for newPostJson in arrayOfPosts {
                let newPostDictionary:NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                let newPost:BOPost = BOPost.MR_importFromObject(newPostDictionary)
                print("New Post generated: "+newPost.name!)
            }
            
            
                // Tracking
                Flurry.logEvent("/posting/download/completed_successful")
            })
            { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                //TODO: handle errors
                print(error)
                
                // Tracking
                Flurry.logEvent("/posting/upload/completed_error")
        }*/
    }
    
// MARK: Upload Postings
    
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
    
    
// MARK: - HELPERS
    func addIDsToNotYetLoadedPostingsIDs(postingIDs: [Int]) {
        if let restoredArrayOfNotYetDownloadedPostings: [Int] = Pantry.unpack("notYetLoadedPostings") {
            self.arrayOfNotYetDownloadedPostings = restoredArrayOfNotYetDownloadedPostings
            self.arrayOfNotYetDownloadedPostings = self.arrayOfNotYetDownloadedPostings + postingIDs
            Pantry.pack(self.arrayOfNotYetDownloadedPostings, key: "notYetLoadedPostings")
            let maxPostID: Int = self.arrayOfNotYetDownloadedPostings.maxElement()!
            Pantry.pack(maxPostID, key: "lastKnownPostingID")
            print("Stored the maximum PostID (", maxPostID, ")")
        }else {
            Pantry.pack(postingIDs, key: "notYetLoadedPostings")
        }
    }
    
    func removeIDsFromNotYetLoadedPostingsIDs(postingIDsArray: [Int]){
        if let restoredArrayOfNotYetDownloadedPostings: [Int] = Pantry.unpack("notYetLoadedPostings")! {
            print("NotYetLoadedPostingsIDs BEFORE deleting:")
            print(restoredArrayOfNotYetDownloadedPostings)
            
            var newPostingIDsArray: [Int] = [Int]()
            for postingID: Int in restoredArrayOfNotYetDownloadedPostings {
                if postingIDsArray.contains(postingID)==false {
                    newPostingIDsArray += [postingID]
                }
            }
            self.arrayOfNotYetDownloadedPostings = newPostingIDsArray
            Pantry.pack(self.arrayOfNotYetDownloadedPostings, key: "notYetLoadedPostings")
            print("NotYetLoadedPostingsIDs AFTER deleting:")
            print(self.arrayOfNotYetDownloadedPostings)
        }
    }
    
    func resetAllCachedIDs() {
        Pantry.expire("notYetLoadedPostings")
        Pantry.expire("lastKnownPostingID")
    }
}
