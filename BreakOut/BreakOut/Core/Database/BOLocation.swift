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


@objc(BOLocation)
class BOLocation: NSManagedObject{
    @NSManaged var uid: NSInteger
    @NSManaged var timestamp: NSDate
    @NSManaged var longitude: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var flagNeedsUpload: Bool
    @NSManaged var teamId: NSInteger
    @NSManaged var teamName: String

    
    class func create(uid: Int, flagNeedsUpload: Bool) -> BOLocation {
        let res = BOLocation.MR_createEntity()! as BOLocation
        res.uid = uid as NSInteger
        res.flagNeedsUpload = flagNeedsUpload
        // Save
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        return res;
    }
    
    class func createWithDictionary(dict: NSDictionary) -> BOLocation {
        let res = BOLocation.MR_createEntity()! as BOLocation
        
        res.setAttributesWithDictionary(dict)
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        
        return res
    }
    
    func initWithDictionary(dict: NSDictionary){
        
    }
    func setAttributesWithDictionary(dict: NSDictionary) {
        //self.uid = dict.valueForKey("id") as! NSInteger
        let unixTimestamp = dict.valueForKey("date") as! NSNumber
        self.timestamp = NSDate(timeIntervalSince1970: unixTimestamp.doubleValue)
        self.latitude = (dict.valueForKey("latitude") as? NSNumber)!
        self.longitude = (dict.valueForKey("longitude") as? NSNumber)!
    }
    
    func save() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
    
    func printToLog() {
        print("----------- BOPost -----------")
        print("ID: ", self.uid)
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
            
            if let responseDict = response as? NSDictionary, lat = responseDict["latitude"] as? Double {
                self.latitude = lat
                
            }
            // Tracking
            self.flagNeedsUpload = false
            self.save()
            //Flurry.logEvent("/posting/upload/completed_successful")
        }) { (error, response) in
            // Tracking
            //Flurry.logEvent("/posting/upload/completed_error")
        }
    }
}