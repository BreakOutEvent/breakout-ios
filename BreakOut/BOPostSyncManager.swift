//
//  File.swift
//  BreakOut
//
//  Created by Mathias Quintero on 9/26/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation
import Flurry_iOS_SDK

class BOPostSyncManager: BOSyncManager {
    
    required init() { }
    
    func uploadMissing() {
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
    
    func dowloadMisisng() {
        self.downloadNotYetLoadedPostings()
    }
    
    func downloadArrayOfNewPostingIDsSinceLastKnownPostingID() {
        if let lastKnownPosting: BOPost = BOPost.mr_findFirstOrdered(byAttribute: "uuid", ascending: false) {
            self.downloadArrayOfNewPostingIDs(since: lastKnownPosting.uuid)
        } else {
            self.downloadArrayOfNewPostingIDs(since: 0)
        }
    }
    
    func downloadArrayOfNewPostingIDs(since lastID: Int) {
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
        BONetworkManager.doJSONRequestGET(.Postings, arguments: [], parameters: nil, auth: false, success: { (response) in
            var numberOfAddedPosts: Int = 0
            for newPosting: NSDictionary in response as? Array ?? [] {
                BOPost.createWithDictionary(newPosting)
                numberOfAddedPosts += 1
            }
            Flurry.logEvent("/posting/download/completed_successful", withParameters: ["API-Path":"GET: posting/", "Number of downloaded Postings":numberOfAddedPosts])
        }) { (error, response) in
            Flurry.logEvent("/posting/download/completed_error", withParameters: ["API-Path":"GET: posting/"])
        }
    }
    
}
