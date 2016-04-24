//
//  BOPost.swift
//  BreakOut
//
//  Created by Leo Käßner on 28.11.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import Foundation

// Database
import MagicalRecord

// Tracking
import Flurry_iOS_SDK

@objc(BOPost)
class BOPost: NSManagedObject {
    @NSManaged var uuid: NSInteger
    @NSManaged var text: String?
    @NSManaged var city: String?
    @NSManaged var date: NSDate
    @NSManaged var longitude: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var flagNeedsUpload: Bool
    @NSManaged var flagNeedsDownload: Bool
    
    class func create(uuid: Int, flagNeedsDownload: Bool) -> BOPost {
        let res = BOPost.MR_createEntity()! as BOPost
        
        res.uuid = uuid as NSInteger
        res.flagNeedsDownload = flagNeedsDownload
        // Save
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        return res;
    }
    
    class func createWithDictionary(dict: NSDictionary) -> BOPost {
        let res = BOPost.MR_createEntity()! as BOPost
        
        res.setAttributesWithDictionary(dict)
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        
        return res
    }
    
    func setAttributesWithDictionary(dict: NSDictionary) {
        self.uuid = dict.valueForKey("id") as! NSInteger
        self.text = dict.valueForKey("text") as? String
        let unixTimestamp = dict.valueForKey("date") as! NSNumber
        self.date = NSDate(timeIntervalSince1970: unixTimestamp.doubleValue)
        if let longitude: NSNumber = dict.valueForKey("postingLocation")!.valueForKey("longitude") as? NSNumber {
            self.longitude = longitude
        }
        if let latitude: NSNumber = dict.valueForKey("postingLocation")!.valueForKey("longitude") as? NSNumber {
            self.longitude = latitude
        }
    }
    
    func save() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
    
    func printToLog() {
        print("----------- BOPost -----------")
        print("ID: ", self.uuid)
        print("Text: ", self.text)
        print("Date: ", self.date.description)
        print("longitude: ", self.longitude)
        print("latitude: ", self.latitude)
        print("flagNeedsUpload: ", self.flagNeedsUpload)
        print("flagNeedsDownload: ", self.flagNeedsDownload)
        print("----------- ------ -----------")
    }
    
    func upload() {
        // New request manager with our backend URL as baseURL
        let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL(string: PrivateConstants.backendURL))
        
        // Sets the serialization of parameters to JSON format
        requestManager.requestSerializer = AFJSONRequestSerializer()
        
        // Get the Dictionary representation of the Post-Object (self)
        let selfDictionary: Dictionary = self.dictionaryWithValuesForKeys(["uuid","name","flagNeedsUpload"])
        
        // Send POST request to backend and set the 'flagNeedsUpload' attribute to false if successful
        requestManager.POST("user/", parameters: selfDictionary,
            success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                print("Upload Post Response: ")
                print(response)
                
                // Tracking
                Flurry.logEvent("/posting/upload/completed_successful")
            })
            { (operation: AFHTTPRequestOperation?, error:NSError) -> Void in
                print("ERROR: While uploading Post")
                print(error)
                
                // TODO: Show detailed errors to the user
                
                // Tracking
                Flurry.logEvent("/posting/upload/completed_error")
        }
    }
}