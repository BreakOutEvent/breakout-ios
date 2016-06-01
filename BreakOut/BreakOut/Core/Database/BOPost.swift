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
    @NSManaged var team: BOTeam?
    @NSManaged var challenge: BOChallenge?
    @NSManaged var images: Set<BOImage>
    @NSManaged var comments: Set<BOComment>
    @NSManaged var country: String?
    @NSManaged var locality: String?
    
    class func create(uuid: Int, flagNeedsDownload: Bool) -> BOPost {
        
        if let origPostArray = BOPost.MR_findByAttribute("uuid", withValue: uuid) as? Array<BOPost>, post = origPostArray.first {
            post.flagNeedsDownload = false
            return post
        }
        
        let res = BOPost.MR_createEntity()! as BOPost
        
        res.uuid = uuid as NSInteger
        res.flagNeedsDownload = flagNeedsDownload
        //res.date = NSDate()
        res.images = Set<BOImage>()
        res.comments = Set<BOComment>()
        
        // Save
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion(nil)
        return res;
    }
    
    class func createWithDictionary(dict: NSDictionary) -> BOPost {
        let res: BOPost
        if let id = dict["id"] as? NSInteger,
                origPostArray = BOPost.MR_findByAttribute("uuid", withValue: id) as? Array<BOPost>,
                post = origPostArray.first {
            res = post
        } else {
            res = BOPost.MR_createEntity()!
        }
        
        res.setAttributesWithDictionary(dict)
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion(nil)
        
        return res
    }
    
    func setAttributesWithDictionary(dict: NSDictionary) {
        self.uuid = dict.valueForKey("id") as! NSInteger
        self.text = dict.valueForKey("text") as? String
        self.comments = Set<BOComment>()
        let unixTimestamp = dict.valueForKey("date") as! NSNumber
        self.date = NSDate(timeIntervalSince1970: unixTimestamp.doubleValue)
        
        if let longitude: NSNumber = dict.valueForKey("postingLocation")!.valueForKey("longitude") as? NSNumber {
            self.longitude = longitude
        }
        if let latitude: NSNumber = dict.valueForKey("postingLocation")!.valueForKey("latitude") as? NSNumber {
            self.latitude = latitude
        }
        
        if let mediaArray = dict.valueForKey("media") as? [NSDictionary] {
            for item in mediaArray {
                BOImage.createFromDictionary(item) { (image) in
                    self.images.insert(image)
                    self.save()
                }
            }
        }
        if let commentsArray = dict.valueForKey("comments") as? [NSDictionary] {
            for item in commentsArray {
                comments.insert(BOComment.createWithDictionary(item))
            }
        }
        
        if let userDictionary = dict.valueForKey("user") as? NSDictionary {
            if let participantDictionary = userDictionary.valueForKey("participant") as? NSDictionary {
                let teamid = participantDictionary.valueForKey("teamId")
                self.addTeamWithId(teamid as? Int ?? -1)
            }
        }
        
        if let postingLocationDictionary = dict.valueForKey("postingLocation") as? NSDictionary {
            if postingLocationDictionary.count > 0 {
                if let locationDataDict: NSDictionary = postingLocationDictionary["locationData"] as? NSDictionary {
                    if locationDataDict["COUNTRY"] != nil {
                        self.country = locationDataDict["COUNTRY"] as! String
                    }
                    if locationDataDict["LOCALITY"] != nil {
                        self.locality = locationDataDict["LOCALITY"] as! String
                    }
                }
            }
        }
        
        
        
        self.save()
        
        print("Set new attributes for BOPost with Dictionary")
        self.printToLog()
    }
    
    func addTeamWithId(teamId: Int) {
        if let teamArray = BOTeam.MR_findByAttribute("uuid", withValue: teamId) as? Array<BOTeam>,
            origTeam = teamArray.first {
            team = self.managedObjectContext?.objectWithID(origTeam.objectID) as! BOTeam
        } else {
            // No Team with the given ID was found (locally)
        }
    }
    
    func save() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
    
    override func didSave() {
        super.didSave()
        if NSManagedObjectContext.MR_defaultContext() != self.managedObjectContext {
            return
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_DB_BOPOST_DID_SAVE, object: nil)
    }
    
    func printToLog() {
        print("----------- BOPost -----------")
        print("ID: ", self.uuid)
        print("Text: ", self.text)
        print("Date: ", self.date.description)
        print("longitude: ", self.longitude)
        print("latitude: ", self.latitude)
        print("locality: ", self.locality)
        print("country: ", self.country)
        print("city: ", self.city)
        print("flagNeedsUpload: ", self.flagNeedsUpload)
        print("flagNeedsDownload: ", self.flagNeedsDownload)
        print("----------- ------ -----------")
    }
    
    func reload(handler: (() -> ())? = nil) {
        if BOSynchronizeController.sharedInstance.internetReachability == "wifi" {
            BONetworkManager.doJSONRequestGET(BackendServices.PostingByID, arguments: [uuid], parameters: nil, auth: false) { (response) in
                if let dict = response as? NSDictionary {
                    self.setAttributesWithDictionary(dict)
                    if let f = handler {
                        f()
                    }
                }
            }
        }
    }
    
    func upload() {
        var dict = [String:AnyObject]()
        
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
                
                if self.challenge != nil {
                    self.challenge?.postingId = self.uuid
                    self.challenge?.status = "with_proof"
                    self.challenge?.flagNeedsUpload = true
                    
                    self.challenge?.upload()
                }
            }
            
            self.reload()
            // Tracking
            self.flagNeedsUpload = false
            self.save()
            Flurry.logEvent("/posting/upload/completed_successful")
        }) { (error, response) in
            // Tracking
            Flurry.logEvent("/posting/upload/completed_error")
        }
    }
}