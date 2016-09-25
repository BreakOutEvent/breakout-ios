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
    
    class func create(_ uuid: Int) -> BOChallenge {
        
        if let origChallengeArray = BOChallenge.mr_find(byAttribute: "uuid", withValue: uuid) as? Array<BOChallenge>, let challenge = origChallengeArray.first {
            return challenge
        }
        
        let res = BOChallenge.mr_createEntity()! as BOChallenge
        
        res.uuid = uuid as NSInteger
        
        // Save
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
        return res;
    }
    
    class func createWithDictionary(_ dict: NSDictionary) -> BOChallenge {
        let res: BOChallenge
        if let id = dict["id"] as? NSInteger,
            let origChallengeArray = BOChallenge.mr_find(byAttribute: "uuid", withValue: id) as? Array<BOChallenge>,
            let challenge = origChallengeArray.first {
            res = challenge
        } else {
            res = BOChallenge.mr_createEntity()!
        }
        
        res.setAttributesWithDictionary(dict)
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
        
        return res
    }
    
    func setAttributesWithDictionary(_ dict: NSDictionary) {
        self.uuid = dict.value(forKey: "id") as! NSInteger
        self.teamId = dict.value(forKey: "teamId") as! NSInteger
        self.eventId = dict.value(forKey: "eventId") as! NSInteger
        self.teamName = dict.value(forKey: "team") as? String
        self.text = dict.value(forKey: "description") as? String
        self.amount = dict.value(forKey: "amount") as? NSNumber
        self.status = dict.value(forKey: "status") as? String
        
        self.save()
        
        print("Set new attributes for BOChallenge with Dictionary")
        self.printToLog()
    }
    
    func save() {
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
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
        
        dict["status"] = self.status as AnyObject?;
        dict["postingId"] = self.postingId as AnyObject?
        
        BONetworkManager.doJSONRequestPUT(.ChallengeStatus, arguments: [self.eventId, self.teamId, self.uuid], parameters: dict as AnyObject, auth: true, success: { (response) in
            
            if let responseDict = response as? NSDictionary, let id = responseDict["id"] as? Int, let status = responseDict["status"] as? String {
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
