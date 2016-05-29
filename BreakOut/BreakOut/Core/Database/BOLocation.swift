//
//  BOLocation.swift
//  BreakOut
//
//  Created by Leo Käßner on 17.04.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation

// Database
import MagicalRecord

// Tracking
import Flurry_iOS_SDK
import Crashlytics


@objc(BOLocation)
class BOLocation: NSManagedObject{
    @NSManaged var uid: NSInteger
    @NSManaged var timestamp: NSDate
    @NSManaged var longitude: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var flagNeedsUpload: Bool
    @NSManaged var teamId: NSInteger
    @NSManaged var teamName: String
    @NSManaged var country: String?
    @NSManaged var locality: String?

    
    class func create(uid: Int, flagNeedsUpload: Bool) -> BOLocation {
        if let origLocationArray = BOLocation.MR_findByAttribute("uid", withValue: uid) as? Array<BOLocation>, location = origLocationArray.first {
            return location
        }
        
        let res = BOLocation.MR_createEntity()! as BOLocation
        
        res.uid = uid as NSInteger
        res.flagNeedsUpload = flagNeedsUpload
        // Save
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion(nil)
        return res;
    }
    
    class func createWithDictionary(dict: NSDictionary) -> BOLocation {
        let res: BOLocation
        if let id = dict["id"] as? NSInteger,
            origLocationArray = BOLocation.MR_findByAttribute("uid", withValue: id) as? Array<BOLocation>,
            location = origLocationArray.first {
            res = location
        } else {
            res = BOLocation.MR_createEntity()!
        }
        
        res.setAttributesWithDictionary(dict)
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion(nil)
        
        return res
    }
    
    func initWithDictionary(dict: NSDictionary){
        
    }
    func setAttributesWithDictionary(dict: NSDictionary) {
        if (dict["id"] != nil) {
            self.uid = dict.valueForKey("id") as! NSInteger
        }
        self.teamId = dict.valueForKey("teamId") as! NSInteger
        self.teamName = dict.valueForKey("team") as! String
        let unixTimestamp = dict.valueForKey("date") as! NSNumber
        self.timestamp = NSDate(timeIntervalSince1970: unixTimestamp.doubleValue)
        self.latitude = (dict.valueForKey("latitude") as? NSNumber)!
        self.longitude = (dict.valueForKey("longitude") as? NSNumber)!
        
        if let locationDataDict: NSDictionary = dict["locationData"] as? NSDictionary {
            if locationDataDict["COUNTRY"] != nil {
                self.country = locationDataDict["COUNTRY"] as! String
            }
            if locationDataDict["LOCALITY"] != nil {
                self.locality = locationDataDict["LOCALITY"] as! String
            }
        }
    }
    
    func save() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion(nil)
    }
    
    func printToLog() {
        print("----------- BOPost -----------")
        print("ID: ", self.uid)
        print("TeamID: ", self.teamId)
        print("TeamName: ", self.teamName)
        print("Timestamp: ", self.timestamp.description)
        print("longitude: ", self.longitude)
        print("latitude: ", self.latitude)
        print("flagNeedsUpload: ", self.flagNeedsUpload)
        print("----------- ------ -----------")
    }
    
    func upload() {
        var dict = [String:AnyObject]()
        
        dict["latitude"] = self.latitude;
        dict["longitude"] = self.longitude;
        dict["date"] = timestamp.timeIntervalSince1970
        
        BONetworkManager.doJSONRequestPOST(.EventTeamLocation, arguments: [CurrentUser.sharedInstance.currentEventId(),CurrentUser.sharedInstance.currentTeamId()], parameters: dict, auth: true, success: { (response) in
            
            if let responseDict = response as? NSDictionary, lat = responseDict["latitude"] as? Double, long = responseDict["longitude"] as? Double, uid = responseDict["id"] as? Int {
                if self.managedObjectContext != nil {
                    self.latitude = lat
                    self.longitude = long
                    self.uid = uid
                }else{
                    print("ERROR: BOLocation couldn't be updated because of NSObjectInaccessibleException")
                }
            }
            // Tracking
            self.flagNeedsUpload = false
            self.save()
            //Flurry.logEvent("/posting/upload/completed_successful")
            Answers.logCustomEventWithName("/BOLocation/upload", customAttributes: ["result":"successful"])
        }) { (error, response) in
            // Tracking
            //Flurry.logEvent("/posting/upload/completed_error")
            Answers.logCustomEventWithName("/BOLocation/upload", customAttributes: ["result":"error"])
        }
    }
}