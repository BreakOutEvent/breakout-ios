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
        self.tryUploadAll()
        self.downloadAllPostings()
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
                    self.tryUploadAll()
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
                totalDatabaseSynchronization()
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
    
// MARK: Events
    
    func sendInvitationToTeam(teamID: Int, name: String, eventID: Int, handler: () -> ()) {
        
        //TODO: Which parameter need to be passed to the API-Endpoint?
        let params: NSDictionary = [
            "event": eventID,
            "name": name
        ]
        
        BONetworkManager.doJSONRequestPOST(.EventInvitation, arguments: [eventID, teamID], parameters: params, auth: true, success: { (response) in
            CurrentUser.sharedInstance.setAttributesWithJSON(response as! NSDictionary)
            handler()
        }) { (_,_) in
            handler()
        }
    }
    
    func getAllEvents(success: ([BOEvent]) -> ()) {
        BONetworkManager.doJSONRequestGET(.Event, arguments: [], parameters: nil, auth: true, success: { (response) in
            if let responseArray: Array = response as? Array<NSDictionary> {
                var res = [BOEvent]()
                for eventDictionary: NSDictionary in responseArray {
                    let newEvent: BOEvent = BOEvent(id: (eventDictionary["id"] as? Int)!, title: (eventDictionary["title"] as? String)!, dateUnixTimestamp: (eventDictionary["date"] as? Int)!, city:(eventDictionary["city"] as? String)!)
                    res.append(newEvent)
                }
                success(res)
            } else {
                success([])
            }
        }) { (error, response) in
            if response?.statusCode == 401 {
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN, object: nil)
            }
        }
    }
    
    func createTeam(name: String, eventID: Int, success: () -> (), error: () -> ()) {
        let params: NSDictionary = [
            "event": eventID,
            "name": name
        ]
        BONetworkManager.doJSONRequestPOST(BackendServices.EventTeam, arguments: [eventID], parameters: params, auth: true, success: { (response) in
            
            // TODO: Do something with the response
            success()
        }) { (err, response) in
            // TODO: Maybe show something more to the user
            error()
        }
    }
    
    
// MARK: Participant
    
    func becomeParticipant(firstName: String, lastname: String, gender: String, email: String, emergencyNumber: String, phone: String, shirtSize: String, success: () -> (), error: () -> ()) {
        
        if let userID = CurrentUser.sharedInstance.userid {
            
            let participantParams: NSDictionary = [
                "emergencynumber": emergencyNumber,
                //"hometown": self.hometownTextfield.text!,
                //TODO: Birthday an Backend übertragen
                "phonenumber": phone,
                "tshirtsize": shirtSize
            ]
            let params: NSDictionary = [
                "firstname": firstName,
                "lastname": lastname,
                "email": email,
                "gender": gender,
                "participant": participantParams
            ]
            
            BONetworkManager.doJSONRequestPUT(.UserData, arguments: [userID], parameters: params, auth: true, success: { (response) in
                CurrentUser.sharedInstance.setAttributesWithJSON(response as! NSDictionary)
                
                // Tracking
                Flurry.logEvent("/user/becomeParticipant/completed_successful")
                success()
            }) { (err, response) in
                
                // TODO: Show detailed errors to the user
                if response?.statusCode == 401 {
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN, object: nil)
                }
                error()
                
            }
        }
        
    }
    
// MARK: Posts List    
    // Similar to functions above ;)
    
// MARK: Likes & Comments
    // Similar to functions above ;)

    
    func testPostUploads() {
        let newPost: BOPost = BOPost.MR_createEntity()!
        
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
        if let lastKnownPosting: BOPost = BOPost.MR_findFirstOrderedByAttribute("uuid", ascending: false) {
            self.downloadArrayOfNewPostingIDsSince(lastKnownPosting.uuid)
        }else{
            self.downloadArrayOfNewPostingIDsSince(0)
        }
    }
    
    func downloadArrayOfNewPostingIDsSince(lastID: Int) {
        BONetworkManager.doJSONRequestGET(.PostingsSince, arguments: [lastID], parameters: nil, auth: false, success: { (response) in
            let arrayOfPostingIDs: [Int] = response as! [Int]
            for newPostingID: Int in arrayOfPostingIDs {
                let newPosting: BOPost = BOPost.create(newPostingID, flagNeedsDownload: true)
                newPosting.printToLog()
            }
        })
    }
    
    func downloadNotYetLoadedPostings() {
        let arrayOfNotYetLoadedPostings: Array = BOPost.MR_findByAttribute("flagNeedsDownload", withValue: true) as! Array<BOPost>
        if arrayOfNotYetLoadedPostings.count > 0 {
            var arrayOfIDsToLoad: [Int] = [Int]()
            var count:Int = 100
            for notYetLoadedPosting:BOPost in arrayOfNotYetLoadedPostings {
                arrayOfIDsToLoad += [notYetLoadedPosting.uuid]
                count -= 1
                if count <= 0 {
                    break
                }
            }
            
            BONetworkManager.doJSONRequestPOST(.NotLoadedPostings, arguments: [], parameters: arrayOfIDsToLoad, auth: false, success: { (response) in
                // response is an Array of Posting Dictionaries
                let arrayOfPostingDictionaries: Array = response as! Array<NSDictionary>
                for newPostingDict: NSDictionary in arrayOfPostingDictionaries {
                    let updatedPost: BOPost = BOPost.MR_findFirstByAttribute("flagNeedsDownload", withValue: true)!
                    updatedPost.setAttributesWithDictionary(newPostingDict)
                    updatedPost.flagNeedsDownload = false
                    updatedPost.printToLog()
                }
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                //BOToast.log("Successfully downloaded and stored \(arrayOfPostingDictionaries.count) Postings")
                // Tracking
                Flurry.logEvent("/posting/download/completed_successful", withParameters: ["API-Path":"POST: posting/get/ids", "Number of IDs asked for":arrayOfIDsToLoad.count])
            }) { (error, response) in
                Flurry.logEvent("/posting/download/completed_error", withParameters: ["API-Path":"POST: posting/get/ids", "Number of IDs asked for":arrayOfIDsToLoad.count])
            }
        }
    }
    
    func downloadAllPostings() {
        
        //TESTING
        /*if let restoredArrayOfNotYetDownloadedPostings: [Int] = Pantry.unpack("notYetLoadedPostings")! {
            self.arrayOfNotYetDownloadedPostings = restoredArrayOfNotYetDownloadedPostings
            self.arrayOfNotYetDownloadedPostings = self.arrayOfNotYetDownloadedPostings + [3,4,5]
            Pantry.pack(self.arrayOfNotYetDownloadedPostings, key: "notYetLoadedPostings")
        }else {
            Pantry.pack([0], key: "notYetLoadedPostings")
        }*/
        
        
        BONetworkManager.doJSONRequestGET(.Postings, arguments: [], parameters: nil, auth: false, success: { (response) in
            var numberOfAddedPosts: Int = 0
            // response is an Array of Posting Objects
            for newPosting: NSDictionary in response as! Array {
                BOPost.createWithDictionary(newPosting)
                //newPost.printToLog()
                numberOfAddedPosts += 1
            }
            //BOToast.log("Downloading all postings was successful \(numberOfAddedPosts)")
            // Tracking
            Flurry.logEvent("/posting/download/completed_successful", withParameters: ["API-Path":"GET: posting/", "Number of downloaded Postings":numberOfAddedPosts])
        }) { (error, response) in
            // TODO: Handle Errors
            Flurry.logEvent("/posting/download/completed_error", withParameters: ["API-Path":"GET: posting/"])
        }
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
    /*func addIDsToNotYetLoadedPostingsIDs(postingIDs: [Int]) {
        if let restoredArrayOfNotYetDownloadedPostings: [Int] = Pantry.unpack("notYetLoadedPostings") {
            self.arrayOfNotYetDownloadedPostings = restoredArrayOfNotYetDownloadedPostings
            self.arrayOfNotYetDownloadedPostings = self.arrayOfNotYetDownloadedPostings + postingIDs
            Pantry.pack(self.arrayOfNotYetDownloadedPostings, key: "notYetLoadedPostings")

            var maxPostID: Int = 0
            
            if self.arrayOfNotYetDownloadedPostings.count > 0 {
                if let restoredLastKnownPostingID: Int = Pantry.unpack("") {
                    if restoredLastKnownPostingID < self.arrayOfNotYetDownloadedPostings.maxElement()! {
                        maxPostID = self.arrayOfNotYetDownloadedPostings.maxElement()!
                    }else{
                        maxPostID = restoredLastKnownPostingID
                    }
                }
            }
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
    }*/
}
