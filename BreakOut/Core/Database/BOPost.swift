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
    @NSManaged var date: Date
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
    
    class func create(_ uuid: Int, flagNeedsDownload: Bool) -> BOPost {
        
        if let origPostArray = BOPost.mr_find(byAttribute: "uuid", withValue: uuid) as? Array<BOPost>, let post = origPostArray.first {
            post.flagNeedsDownload = false
            return post
        }
        
        let res = BOPost.mr_createEntity()! as BOPost
        
        res.uuid = uuid as NSInteger
        res.flagNeedsDownload = flagNeedsDownload
        //res.date = NSDate()
        res.images = Set<BOImage>()
        res.comments = Set<BOComment>()
        
        // Save
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
        return res;
    }
    
    class func createWithDictionary(_ dict: NSDictionary) -> BOPost {
        let res: BOPost
        if let id = dict["id"] as? NSInteger,
                let origPostArray = BOPost.mr_find(byAttribute: "uuid", withValue: id) as? Array<BOPost>,
                let post = origPostArray.first {
            res = post
        } else {
            res = BOPost.mr_createEntity()!
        }
        
        res.setAttributesWithDictionary(dict)
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
        
        return res
    }
    
    func setAttributesWithDictionary(_ dict: NSDictionary) {
        self.uuid = dict.value(forKey: "id") as! NSInteger
        self.text = dict.value(forKey: "text") as? String
        self.comments = Set<BOComment>()
        let unixTimestamp = dict.value(forKey: "date") as! NSNumber
        self.date = Date(timeIntervalSince1970: unixTimestamp.doubleValue)
        
        if let longitude: NSNumber = (dict.value(forKey: "postingLocation")! as AnyObject).value(forKey: "longitude") as? NSNumber {
            self.longitude = longitude
        }
        if let latitude: NSNumber = (dict.value(forKey: "postingLocation")! as AnyObject).value(forKey: "latitude") as? NSNumber {
            self.latitude = latitude
        }
        
        if let mediaArray = dict.value(forKey: "media") as? [NSDictionary] {
            for item in mediaArray {
                BOImage.createFromDictionary(item) { (image) in
                    self.images.insert(image)
                    self.save()
                }
            }
        }
        if let commentsArray = dict.value(forKey: "comments") as? [NSDictionary] {
            for item in commentsArray {
                comments.insert(BOComment.createWithDictionary(item))
            }
        }
        
        if let userDictionary = dict.value(forKey: "user") as? NSDictionary {
            if let participantDictionary = userDictionary.value(forKey: "participant") as? NSDictionary {
                let teamid = participantDictionary.value(forKey: "teamId")
                self.addTeamWithId(teamid as? Int ?? -1)
            }
        }
        
        if let postingLocationDictionary = dict.value(forKey: "postingLocation") as? NSDictionary {
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
    
    func addTeamWithId(_ teamId: Int) {
        if let teamArray = BOTeam.mr_find(byAttribute: "uuid", withValue: teamId) as? Array<BOTeam>,
            let origTeam = teamArray.first {
            team = self.managedObjectContext?.object(with: origTeam.objectID) as! BOTeam
        } else {
            // No Team with the given ID was found (locally)
        }
    }
    
    func save() {
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    override func didSave() {
        super.didSave()
        if NSManagedObjectContext.mr_default() != self.managedObjectContext {
            return
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_DB_BOPOST_DID_SAVE), object: nil)
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
    
    func reload(_ handler: (() -> ())? = nil) {
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
        
        dict["text"] = text as AnyObject?;
        dict["date"] = date.timeIntervalSince1970 as AnyObject?

        var postingLocation = [String:AnyObject]()
        postingLocation["latitude"] = latitude
        postingLocation["longitude"] = longitude
        
        dict["postingLocation"] = postingLocation as AnyObject?
        
        let img = images.map() { $0 as BOImage }
        
        dict["uploadMediaTypes"] = img.map() { $0.type } as AnyObject

        BONetworkManager.doJSONRequestPOST(.Postings, arguments: [], parameters: dict, auth: true, success: { (response) in
            
            if let responseDict = response as? NSDictionary, let id = responseDict["id"] as? Int, let mediaArray = responseDict["media"] as? [NSDictionary] {
                self.uuid = id
                if !mediaArray.isEmpty {
                    for i in 0...(mediaArray.count-1) {
                        let respondedMediaItem = mediaArray[i]
                        let mediaItem = img[i]
                        if let id = respondedMediaItem["id"] as? Int, let token = respondedMediaItem["uploadToken"] as? String {
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
