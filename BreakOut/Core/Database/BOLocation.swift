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
    @NSManaged var timestamp: Date
    @NSManaged var longitude: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var flagNeedsUpload: Bool
    @NSManaged var teamId: NSInteger
    @NSManaged var teamName: String
    @NSManaged var country: String?
    @NSManaged var locality: String?

    
    class func create(_ uid: Int, flagNeedsUpload: Bool) -> BOLocation {
        if let origLocationArray = BOLocation.mr_find(byAttribute: "uid", withValue: uid) as? Array<BOLocation>, let location = origLocationArray.first {
            return location
        }
        
        let res = BOLocation.mr_createEntity()! as BOLocation
        
        res.uid = uid as NSInteger
        res.flagNeedsUpload = flagNeedsUpload
        // Save
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
        return res;
    }
    
    class func createWithDictionary(_ dict: NSDictionary) -> BOLocation {
        let res: BOLocation
        /*if let id = dict["id"] as? NSInteger,
            origLocationArray = BOLocation.MR_findByAttribute("uid", withValue: id) as? Array<BOLocation>,
            location = origLocationArray.first {
            res = location
        } else {*/
            res = BOLocation.mr_createEntity()!
        //}
        
        res.setAttributesWithDictionary(dict)
        
        //dispatch_async(dispatch_get_main_queue()) {
            NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
        //}
        
        
        return res
    }
    
    func initWithDictionary(_ dict: NSDictionary){
        
    }
    func setAttributesWithDictionary(_ dict: NSDictionary) {
        if (dict["id"] != nil) {
            self.uid = dict.value(forKey: "id") as! NSInteger
        }
        self.teamId = dict.value(forKey: "teamId") as! NSInteger
        self.teamName = dict.value(forKey: "team") as! String
        let unixTimestamp = dict.value(forKey: "date") as! NSNumber
        self.timestamp = Date(timeIntervalSince1970: unixTimestamp.doubleValue)
        self.latitude = (dict.value(forKey: "latitude") as? NSNumber)!
        self.longitude = (dict.value(forKey: "longitude") as? NSNumber)!
        
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
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
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
        if BOSynchronizeController.shared.isReachable {
            var dict = [String:AnyObject]()
            
            dict["latitude"] = self.latitude;
            dict["longitude"] = self.longitude;
            dict["date"] = timestamp.timeIntervalSince1970 as AnyObject?
            
            BONetworkManager.doJSONRequestPOST(.EventTeamLocation, arguments: [CurrentUser.shared.currentEventId(),CurrentUser.shared.currentTeamId()], parameters: dict, auth: true, success: { (response) in
                
                if let responseDict = response as? NSDictionary, let lat = responseDict["latitude"] as? Double, let long = responseDict["longitude"] as? Double, let uid = responseDict["id"] as? Int {
                    if self.managedObjectContext != nil {
                        self.latitude = NSNumber(value: lat)
                        self.longitude = NSNumber(value: long)
                        self.uid = uid
                    }else{
                        print("ERROR: BOLocation couldn't be updated because of NSObjectInaccessibleException")
                    }
                }
                // Tracking
                self.flagNeedsUpload = false
                self.save()
                //Flurry.logEvent("/posting/upload/completed_successful")
                Answers.logCustomEvent(withName: "/BOLocation/upload", customAttributes: ["result":"successful"])
            }) { (error, response) in
                // Tracking
                //Flurry.logEvent("/posting/upload/completed_error")
                Answers.logCustomEvent(withName: "/BOLocation/upload", customAttributes: ["result":"error"])
            }
        }
    }
}
