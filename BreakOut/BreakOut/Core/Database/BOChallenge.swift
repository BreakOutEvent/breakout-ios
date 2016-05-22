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
    @NSManaged var postingId: NSInteger
    @NSManaged var eventId: NSInteger
    @NSManaged var teamId: NSInteger
    @NSManaged var teamName: String?
    @NSManaged var text: String?
    @NSManaged var status: String?
    @NSManaged var amount: NSNumber?
    @NSManaged var flagNeedsUpload: Bool
    
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
        print("PostingId: ", self.postingId)
        print("TeamId: ", self.teamId)
        print("TeamName: ", self.teamName)
        print("EventId: ", self.eventId)
        print("Status: ", self.status)
        print("flagNeedsUpload: ", self.flagNeedsUpload)
        print("----------- ------ -----------")
    }
    
    func upload() {
        var dict = [String:AnyObject]()
        
        dict["status"] = self.status;
        dict["postingId"] = self.postingId
        
        BONetworkManager.doJSONRequestPUT(.ChallengeStatus, arguments: [self.eventId, self.teamId, self.uuid], parameters: dict, auth: true, success: { (response) in
            
            if let responseDict = response as? NSDictionary, id = responseDict["id"] as? Int, status = responseDict["status"] as? String {
                self.uuid = id
                self.status = status
                self.flagNeedsUpload = false
            }

            self.save()
            //Flurry.logEvent("/posting/upload/completed_successful")
        }) { (error, response) in
            // Tracking
            //Flurry.logEvent("/posting/upload/completed_error")
        }
    }
}