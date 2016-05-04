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

// MapKit
import MapKit

@objc(BOLocation)
class BOLocation: NSManagedObject, MKAnnotation {
    @NSManaged var uid: NSInteger
    @NSManaged var timestamp: NSDate
    @NSManaged var longitude: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var flagNeedsUpload: Bool
    @NSManaged var coordinate: CLLocationCoordinate2D
    
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
    
    func setAttributesWithDictionary(dict: NSDictionary) {
        self.uid = dict.valueForKey("id") as! NSInteger
        let unixTimestamp = dict.valueForKey("timestamp") as! NSNumber
        self.timestamp = NSDate(timeIntervalSince1970: unixTimestamp.doubleValue)
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude as CLLocationDegrees, longitude: self.longitude as CLLocationDegrees)
        /*if let longitude: NSNumber = dict.valueForKey("postingLocation")!.valueForKey("longitude") as? NSNumber {
            self.longitude = longitude
        }
        if let latitude: NSNumber = dict.valueForKey("postingLocation")!.valueForKey("longitude") as? NSNumber {
            self.longitude = latitude
        }*/
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