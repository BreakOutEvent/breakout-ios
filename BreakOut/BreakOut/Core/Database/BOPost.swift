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
    @NSManaged var images: [BOImage]
    
    class func create(uuid: Int, flagNeedsDownload: Bool) -> BOPost {
        let res = BOPost.MR_createEntity()! as BOPost
        
        res.uuid = uuid as NSInteger
        res.flagNeedsDownload = flagNeedsDownload
        res.date = NSDate()
        
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
        
        var dict = [String:AnyObject]()
        
        dict["text"] = text;
        dict["date"] = date.timeIntervalSince1970

        var postingLocation = [String:AnyObject]()
        postingLocation["latitude"] = latitude
        postingLocation["longitude"] = latitude
        
        dict["postingLocation"] = postingLocation
        
        dict["uploadMediaTypes"] = images.map() { $0.getModelString() }

        BONetworkManager.doJSONRequestPOST(.Postings, arguments: [], parameters: dict, auth: true, success: { (response) in
            
            if let responseDict = response as? NSDictionary, mediaArray = responseDict["media"] as? Array<NSDictionary> {
                for i in 0...(mediaArray.count-1) {
                    let respondedMediaItem = mediaArray[i]
                    let mediaItem = self.images[i]
                    if let id = respondedMediaItem["id"] as? Int, token = respondedMediaItem["uploadToken"] as? String {
                        mediaItem.uploadWithToken(id, token: token)
                    }
                 }
            }
            
            // Tracking
            self.flagNeedsUpload = false
            Flurry.logEvent("/posting/upload/completed_successful")
        }) { (error, response) in
            // Tracking
            Flurry.logEvent("/posting/upload/completed_error")
        }
        
    }
}