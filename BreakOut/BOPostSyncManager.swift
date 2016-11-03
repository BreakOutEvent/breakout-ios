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
        let arrayOfPostsToUpload = BOPost.mr_find(byAttribute: "flagNeedsUpload", withValue: true) as! Array<BOPost>
        
        // Tracking
        Flurry.logEvent("/posting/upload/start", withParameters: ["Number of Posts": arrayOfPostsToUpload.count])
        
        // Start upload process for all offline posts (TODO: Asynchronous)
        arrayOfPostsToUpload.forEach { $0.upload() }
    }
    
    func dowloadMisisng() {
        self.downloadNotYetLoadedPostings()
    }
    
    func downloadArrayOfNewPostingIDsSinceLastKnownPostingID() {
        if let lastKnownPosting = BOPost.mr_findFirstOrdered(byAttribute: "uuid", ascending: false) {
            self.downloadArrayOfNewPostingIDs(since: lastKnownPosting.uuid)
        } else {
            self.downloadArrayOfNewPostingIDs(since: 0)
        }
    }
    
    func downloadArrayOfNewPostingIDs(since lastID: Int) {
        BONetworkManager.get(.PostingsSince, arguments: [lastID], parameters: nil, auth: false, success: { (response) in
            let arrayOfPostingIDs = response as! [Int]
            for newPostingID in arrayOfPostingIDs {
                let newPosting = BOPost.create(newPostingID, flagNeedsDownload: true)
                newPosting.printToLog()
            }
            self.downloadNotYetLoadedPostings()
        })
    }
    
    func downloadNotYetLoadedPostings() {
        let arrayOfNotYetLoadedPostings: Array = BOPost.mr_find(byAttribute: "flagNeedsDownload", withValue: true) as! Array<BOPost>
        if !arrayOfNotYetLoadedPostings.isEmpty {
            let arrayOfIDsToLoad = arrayOfNotYetLoadedPostings.first(100)
            BONetworkManager.post(.NotLoadedPostings, arguments: [], parameters: arrayOfIDsToLoad as AnyObject?, auth: false, success: { (response) in
                
                // response is an Array of Posting Dictionaries
                let arrayOfPostingDictionaries = response as! Array<NSDictionary>
                for newPostingDict in arrayOfPostingDictionaries {
                    let updatedPost = BOPost.mr_findFirst(byAttribute: "flagNeedsDownload", withValue: true)!
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
        BONetworkManager.get(.Postings, arguments: [], parameters: nil, auth: false, success: { (response) in
            let responseArray = response as? [NSDictionary] ?? []
            responseArray.forEach {
                _ = BOPost.createWithDictionary($0)
            }
            Flurry.logEvent("/posting/download/completed_successful", withParameters: ["API-Path":"GET: posting/", "Number of downloaded Postings": responseArray.count])
        }) { (error, response) in
            Flurry.logEvent("/posting/download/completed_error", withParameters: ["API-Path":"GET: posting/"])
        }
    }
    
}
