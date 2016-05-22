//
//  BOChallenge.swift
//  BreakOut
//
//  Created by Leo Käßner on 22.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation

// Database
import MagicalRecord

// Tracking
import Flurry_iOS_SDK

@objc(BOChallenge)
class BOChallenge: NSManagedObject {
    
    @NSManaged var uuid: NSInteger
    @NSManaged var eventId: NSInteger
    @NSManaged var teamId: NSInteger
    @NSManaged var teamName: String?
    @NSManaged var text: String?
    @NSManaged var status: String?
    @NSManaged var amount: NSNumber?
    
    class func create(uuid: Int) -> BOChallenge {
        
        if let origChallengeArray = BOChallenge.MR_findByAttribute("uuid", withValue: uuid) as? Array<BOChallenge>, challenge = origChallengeArray.first {
            return challenge
        }
        
        let res = BOChallenge.MR_createEntity()! as BOChallenge
        
        res.uuid = uuid as NSInteger
        
        // Save
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        return res;
    }
    
    class func createWithDictionary(dict: NSDictionary) -> BOChallenge {
        let res: BOChallenge
        if let id = dict["id"] as? NSInteger,
            origChallengeArray = BOChallenge.MR_findByAttribute("uuid", withValue: id) as? Array<BOChallenge>,
            challenge = origChallengeArray.first {
            res = challenge
        } else {
            res = BOChallenge.MR_createEntity()!
        }
        
        res.setAttributesWithDictionary(dict)
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        
        return res
    }
    
    func setAttributesWithDictionary(dict: NSDictionary) {
        self.uuid = dict.valueForKey("id") as! NSInteger
        self.teamId = dict.valueForKey("teamId") as! NSInteger
        self.eventId = dict.valueForKey("eventId") as! NSInteger
        self.teamName = dict.valueForKey("team") as? String
        self.text = dict.valueForKey("description") as? String
        self.amount = dict.valueForKey("amount") as? NSNumber
        self.status = dict.valueForKey("status") as? String
        
        self.save()
        
        print("Set new attributes for BOChallenge with Dictionary")
        self.printToLog()
    }
    
    func save() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
    
    func printToLog() {
        print("----------- BOChallenge -----------")
        print("ID: ", self.uuid)
        print("Description: ", self.text)
        print("Amount: ", self.amount)
        print("TeamId: ", self.teamId)
        print("TeamName: ", self.teamName)
        print("EventId: ", self.eventId)
        print("Status: ", self.status)
        print("----------- ------ -----------")
    }
    
    func upload() {
        /*var dict = [String:AnyObject]()
        
        dict["text"] = text;
        dict["date"] = date.timeIntervalSince1970
        
        var postingLocation = [String:AnyObject]()
        postingLocation["latitude"] = latitude
        postingLocation["longitude"] = longitude
        
        dict["postingLocation"] = postingLocation
        
        let img = images.map() { $0 as BOImage }
        
        dict["uploadMediaTypes"] = img.map() { $0.type }
        
        BONetworkManager.doJSONRequestPOST(.Postings, arguments: [], parameters: dict, auth: true, success: { (response) in
            
            if let responseDict = response as? NSDictionary, id = responseDict["id"] as? Int, mediaArray = responseDict["media"] as? [NSDictionary] {
                self.uuid = id
                if !mediaArray.isEmpty {
                    for i in 0...(mediaArray.count-1) {
                        let respondedMediaItem = mediaArray[i]
                        let mediaItem = img[i]
                        if let id = respondedMediaItem["id"] as? Int, token = respondedMediaItem["uploadToken"] as? String {
                            mediaItem.uploadWithToken(id, token: token)
                        }
                    }
                }
            }

            self.save()
            //Flurry.logEvent("/posting/upload/completed_successful")
        }) { (error, response) in
            // Tracking
            //Flurry.logEvent("/posting/upload/completed_error")
        }*/
    }
}