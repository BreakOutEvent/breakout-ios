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
        self.uid = dict.valueForKey("teamId") as! NSInteger
        let unixTimestamp = dict.valueForKey("date") as! NSNumber
        self.timestamp = NSDate(timeIntervalSince1970: unixTimestamp.doubleValue)
//         let longitude: NSNumber = dict.valueForKey("postingLocation")!.valueForKey("longitude") as? NSNumber {
//            self.longitude = longitude
//        }
//        if let latitude: NSNumber = dict.valueForKey("postingLocation")!.valueForKey("longitude") as? NSNumber {
//            self.longitude = latitude
//        }
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
}