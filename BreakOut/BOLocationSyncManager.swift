//
//  BOLocationSyncManager.swift
//  BreakOut
//
//  Created by Mathias Quintero on 9/26/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation
class BOLocationSyncManager: BOSyncManager {
    
    required init() { }
    
    func uploadMissing() {
        // LOcations can only be uploaded if the user is logged in and part of a team which participates at an event. Check this before!
        if (CurrentUser.shared.isLoggedIn() && CurrentUser.shared.currentTeamId() >= 0 && CurrentUser.shared.currentEventId() >= 0) {
            if let locationsToUpload = BOLocation.mr_find(byAttribute: "flagNeedsUpload", withValue: true) as? Array<BOLocation> {
                for location in locationsToUpload {
                    location.upload()
                }
            }
        } else {
            print("Can't upload location -- User is not logged in and not in a team")
        }
    }
    
    func dowloadMisisng() { }
    
    func downloadAllLocationsForEvent(_ eventId: Int) {
        BONetworkManager.get(.EventAllLocations, arguments: [eventId], parameters: nil, auth: false, success: { (response) in
            // response is an Array of Location Objects
            for newLocation: NSDictionary in response as! Array {
                DispatchQueue.global(qos: .userInitiated).async {
                    BOLocation.createWithDictionary(newLocation)
                }
            }
            //BOToast.log("Downloading all postings was successful \(numberOfAddedPosts)")
            // Tracking
            //Flurry.logEvent("/posting/download/completed_successful", withParameters: ["API-Path":"GET: posting/", "Number of downloaded Postings":numberOfAddedPosts])
        }) { (error, response) in
            // TODO: Handle Errors
            //Flurry.logEvent("/posting/download/completed_error", withParameters: ["API-Path":"GET: posting/"])
        }
    }
    
    
    
    func downloadArrayOfNewLocationsSinceLastKnownLocationFor(eventId:Int){
        if let lastKnownLocation = BOLocation.mr_findFirstOrdered(byAttribute: "uid", ascending: false) {
            self.downloadArrayOfNewLocationsSince(lastId: lastKnownLocation.uid, for: eventId)
        } else {
            self.downloadArrayOfNewLocationsSince(lastId: 0, for: eventId)
        }
    }
    
    func downloadArrayOfNewLocationsSince(lastId: Int, for eventId: Int){
        BONetworkManager.get(.EventLocationsSince, arguments: [eventId, lastId], parameters: nil, auth: false, success: { (response) in
            // response is Array of BOLocation
            
            for newLocation: NSDictionary in response as! Array {
                BOLocation.createWithDictionary(newLocation)
            }
        }) {(error, response) in
        
        }
    }
}
