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
    
    static let sharedInstance = BOSynchronizeController()
    
    /**
     Makes a total database synchronization of all tables. It starts all Requests for each Database table and stores all repsones. This should only be used at the first start of the app, when no data is in it. Also be carfeully with loading too much data over cellular
    */
    func totalDatabaseSynchronization() {
        //self.loadTotalTeamList();
        self.tryUploadAll()
        //self.downloadNotYetLoadedPostings()
        //self.downloadBestVersionsOfImages()
        // ... and all the other methods.
    }

    
// #############################################################################################
// MARK: - HELPERS
// MARK: Internet Reachability
    
    var reachability: Reachability?
    var internetReachability: String = "unknown"
    
    func isReachableWifiOrCellular() -> Bool {
        if self.internetReachability == "wifi" || self.internetReachability == "cellular" {
            return true
        }
        return false
    }
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
                    
                    self.tryUploadAll()
                    
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
    func loadUpdatesOfTeamList(_ date: Date) {
        
    }
    
    /**
     calculates the last update of the team list and loads new team list updates since then. It uses the `loadUpdatesOfTeamList` Function.
    */
    func loadUpdatesOfTeamListSinceLastUpdate() {
        
    }
    
// MARK: Events
    
    func sendInvitationToTeam(_ teamID: Int, name: String, eventID: Int, handler: @escaping () -> ()) {
        
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
    
    func getAllEvents(_ success: @escaping ([BOEvent]) -> ()) {
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
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN), object: nil)
            }
        }
    }
    
    func createTeam(_ name: String, eventID: Int, image: UIImage?, success: @escaping () -> (), error: @escaping () -> ()) {
        let params: NSDictionary = [
            "event": eventID,
            "name": name
        ]
        BONetworkManager.doJSONRequestPOST(BackendServices.EventTeam, arguments: [eventID], parameters: params, auth: true, success: { (response) in
            if let imageUnwrapped = image, let dict = response as? NSDictionary,
                    let profilePicDict = dict.value(forKey: "profilePic") as? NSDictionary,
                    let token = profilePicDict.value(forKey: "uploadToken") as? String,
                    let id = profilePicDict.value(forKey: "id") as? Int {
                let boImage = BOImage.createWithImage(imageUnwrapped)
                boImage.uploadWithToken(id, token: token)
            }
            if let dict = response as? NSDictionary {
                let team = BOTeam.createWithDictionary(dict)
                CurrentUser.sharedInstance.teamid = team.uuid
                CurrentUser.sharedInstance.storeInNSUserDefaults()
            }
            success()
        }) { (err, response) in
            // TODO: Maybe show something more to the user
            error()
        }
    }
    
    
// MARK: Participant
    
    func becomeParticipant(_ firstName: String, lastname: String, gender: String, email: String, emergencyNumber: String, phone: String, shirtSize: String, success: @escaping () -> (), error: @escaping () -> ()) {
        
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
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN), object: nil)
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
        let newPost: BOPost = BOPost.mr_createEntity()!
        
        newPost.flagNeedsUpload = true
        newPost.text = "test post"
        
        self.tryUploadAll()
    }
    

// MARK: - Uploads
    
    func tryUploadAll() {
        self.tryUploadPosts()
        self.tryUploadComments()
        self.tryUploadLocations()
        self.tryUploadImages()
        /*self.tryUploadLikes()
        self.tryUploadLocations()
        self.tryUploadImages()
        self.tryUploadChatMessanges()*/
    }
    
    func triggerUpload() {
        if internetReachability == "wifi" || internetReachability == "cellular" {
            tryUploadAll()
        }
    }
    
    
// MARK: - Postings
// MARK: Download Postings
    
    func downloadArrayOfNewPostingIDsSinceLastKnownPostingID() {
        if let lastKnownPosting: BOPost = BOPost.mr_findFirstOrdered(byAttribute: "uuid", ascending: false) {
            self.downloadArrayOfNewPostingIDsSince(lastKnownPosting.uuid)
        }else{
            self.downloadArrayOfNewPostingIDsSince(0)
        }
    }
    
    func downloadArrayOfNewPostingIDsSince(_ lastID: Int) {
        BONetworkManager.doJSONRequestGET(.PostingsSince, arguments: [lastID], parameters: nil, auth: false, success: { (response) in
            let arrayOfPostingIDs: [Int] = response as! [Int]
            for newPostingID: Int in arrayOfPostingIDs {
                let newPosting: BOPost = BOPost.create(newPostingID, flagNeedsDownload: true)
                newPosting.printToLog()
            }
            self.downloadNotYetLoadedPostings()
        })
    }
    
    func downloadNotYetLoadedPostings() {
        let arrayOfNotYetLoadedPostings: Array = BOPost.mr_find(byAttribute: "flagNeedsDownload", withValue: true) as! Array<BOPost>
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
            
            BONetworkManager.doJSONRequestPOST(.NotLoadedPostings, arguments: [], parameters: arrayOfIDsToLoad as AnyObject?, auth: false, success: { (response) in
                // response is an Array of Posting Dictionaries
                let arrayOfPostingDictionaries: Array = response as! Array<NSDictionary>
                for newPostingDict: NSDictionary in arrayOfPostingDictionaries {
                    let updatedPost: BOPost = BOPost.mr_findFirst(byAttribute: "flagNeedsDownload", withValue: true)!
                    updatedPost.setAttributesWithDictionary(newPostingDict)
                    updatedPost.flagNeedsDownload = false
                    updatedPost.printToLog()
                }
                NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
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
    
    func downloadIdsOfAllEvents() {
        BONetworkManager.doJSONRequestGET(.Event, arguments: [], parameters: nil, auth: false, success: { (response) in
            for newEvent: NSDictionary in response as! Array {
                
                let defaults = UserDefaults.standard
                defaults.set(newEvent.value(forKey: "date")as! Int, forKey: "eventStartTimestamp")
                defaults.synchronize()
                
                self.downloadAllTeamsForEvent(newEvent.value(forKey: "id")as! Int)
                self.downloadAllLocationsForEvent(newEvent.value(forKey: "id")as! Int)
            }
        }) { (error, response) in
        }
    }
    
    func downloadAllTeamsForEvent(_ eventId: Int) {
        BONetworkManager.doJSONRequestGET(.EventTeam, arguments: [eventId], parameters: nil, auth: false, success: { (response) in
            var numberOfAddedTeams: Int = 0
            // response is an Array of Team Objects
            let arrayExistingTeams: Array<BOTeam> = BOTeam.mr_findAll() as! Array<BOTeam>
            for newTeam: NSDictionary in response as! Array {
                //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let index = arrayExistingTeams.index(where: {$0.uuid == (newTeam.object(forKey: "id") as! Int)})
                    if index != nil {
                        // Team already exists
                    }else{
                        BOTeam.createWithDictionary(newTeam)
                    }
                //})
                //newPost.printToLog()
                numberOfAddedTeams += 1
            }
            //BOToast.log("Downloading all postings was successful \(numberOfAddedPosts)")
            // Tracking
            //Flurry.logEvent("/posting/download/completed_successful", withParameters: ["API-Path":"GET: posting/", "Number of downloaded Postings":numberOfAddedPosts])
        }) { (error, response) in
            // TODO: Handle Errors
            //Flurry.logEvent("/posting/download/completed_error", withParameters: ["API-Path":"GET: posting/"])
        }
    }
    
    func downloadAllLocationsForEvent(_ eventId: Int) {
        BONetworkManager.doJSONRequestGET(.EventAllLocations, arguments: [eventId], parameters: nil, auth: false, success: { (response) in
            // response is an Array of Location Objects
            for newLocation: NSDictionary in response as! Array {
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: {
                    BOLocation.createWithDictionary(newLocation)
                })
            }
            //BOToast.log("Downloading all postings was successful \(numberOfAddedPosts)")
            // Tracking
            //Flurry.logEvent("/posting/download/completed_successful", withParameters: ["API-Path":"GET: posting/", "Number of downloaded Postings":numberOfAddedPosts])
        }) { (error, response) in
            // TODO: Handle Errors
            //Flurry.logEvent("/posting/download/completed_error", withParameters: ["API-Path":"GET: posting/"])
        }
    }
    
    func downloadChallengesForCurrentUser() {
        if CurrentUser.sharedInstance.isLoggedIn() && CurrentUser.sharedInstance.currentTeamId() >= 0 && CurrentUser.sharedInstance.currentEventId() >= 0 {
            self.downloadChallengesForTeam(CurrentUser.sharedInstance.currentTeamId(), eventId: CurrentUser.sharedInstance.currentEventId())
        }
    }
    
    func downloadChallengesForTeam(_ teamId: Int, eventId: Int) {
        BONetworkManager.doJSONRequestGET(.EventTeamChallenge, arguments: [eventId, teamId], parameters: nil, auth: false, success: { (response) in
            // response is an Array of Location Objects
            for newChallenge: NSDictionary in response as! Array {
                BOChallenge.createWithDictionary(newChallenge)
            }
            //BOToast.log("Downloading all postings was successful \(numberOfAddedPosts)")
            // Tracking
            //Flurry.logEvent("/posting/download/completed_successful", withParameters: ["API-Path":"GET: posting/", "Number of downloaded Postings":numberOfAddedPosts])
        }) { (error, response) in
            // TODO: Handle Errors
            //Flurry.logEvent("/posting/download/completed_error", withParameters: ["API-Path":"GET: posting/"])
        }
    }
    
    func downloadBestVersionsOfImages() {
        if let images = BOImage.mr_find(byAttribute: "needsBetterDownload", withValue: true) as? Array<BOImage> {
            for image in images {
                BOImageDownloadManager.sharedInstance.getBetterImage(image.uid)
            }
        }
    }
    
// MARK: Upload Postings
    
    func tryUploadPosts() {
        // Retrieve Array of all posts which are flagged as offline with need to upload
        let arrayOfPostsToUpload: Array = BOPost.mr_find(byAttribute: "flagNeedsUpload", withValue: true) as! Array<BOPost>
        
        // Tracking
        Flurry.logEvent("/posting/upload/start", withParameters: ["Number of Posts": arrayOfPostsToUpload.count])
        
        // Start upload process for all offline posts (TODO: Asynchronous)
        for postToUpload: BOPost in arrayOfPostsToUpload {
            // Start upload function for each BOPost
            postToUpload.upload()
        }
    }
    
// MARK: Upload Comments
    
    func tryUploadComments() {
        if let commentsToUpload = BOComment.mr_find(byAttribute: "flagNeedsUpload", withValue: true) as? Array<BOComment> {
            for comment in commentsToUpload {
                comment.upload()
            }
        }
    }
    
    func tryUploadLocations() {
        // LOcations can only be uploaded if the user is logged in and part of a team which participates at an event. Check this before!
        if (CurrentUser.sharedInstance.isLoggedIn() && CurrentUser.sharedInstance.currentTeamId() >= 0 && CurrentUser.sharedInstance.currentEventId() >= 0) {
            if let locationsToUpload = BOLocation.mr_find(byAttribute: "flagNeedsUpload", withValue: true) as? Array<BOLocation> {
                for location in locationsToUpload {
                    location.upload()
                }
            }
        }else{
            print("Can't upload location -- User is not logged in and not in a team")
        }
        
    }
    
    func tryUploadImages() {
        if internetReachability == "wifi" {
            if (CurrentUser.sharedInstance.isLoggedIn() && CurrentUser.sharedInstance.currentTeamId() >= 0 && CurrentUser.sharedInstance.currentEventId() >= 0) {
                if let imagesToUpload = BOImage.mr_find(byAttribute: "flagNeedsUpload", withValue: true) as? Array<BOImage> {
                    for image in imagesToUpload {
                        image.upload()
                    }
                }
            }else{
                print("Can't upload location -- User is not logged in and not in a team")
            }
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
