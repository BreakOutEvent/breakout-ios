//
//  BOComment.swift
//  BreakOut
//
//  Created by Mathias Quintero on 5/21/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation

// Database
import MagicalRecord

// Tracking
import Flurry_iOS_SDK

@objc(BOComment)
class BOComment: NSManagedObject {
    
    @NSManaged var uuid: NSInteger
    @NSManaged var postID: NSInteger
    @NSManaged var text: String?
    @NSManaged var name: String?
    @NSManaged var date: Date
    @NSManaged var flagNeedsUpload: Bool
    @NSManaged var profilePic: BOImage?
    
    
    class func create(_ uuid: Int, text: String?, postID: NSInteger) -> BOComment {
        let res = BOComment.mr_createEntity()! as BOComment
        res.uuid = uuid as NSInteger
        res.date = Date()
        res.text = text
        res.postID = postID
        res.flagNeedsUpload = true
        if let first = CurrentUser.sharedInstance.firstname, let last = CurrentUser.sharedInstance.lastname {
            res.name = first + " " + last
        }
        //BOSynchronizeController.sharedInstance.triggerUpload()
        
        // Save
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
        return res;
    }
    
    class func createWithDictionary(_ dict: NSDictionary) -> BOComment {
        let res: BOComment
        if let id = dict["id"] as? NSInteger,
            let origPostArray = BOComment.mr_find(byAttribute: "uuid", withValue: id) as? Array<BOComment>,
            let post = origPostArray.first {
            res = post
        } else {
            res = BOComment.mr_createEntity()!
        }
        res.setAttributesWithDictionary(dict)
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
        return res
    }
    
    func setAttributesWithDictionary(_ dict: NSDictionary) {
        uuid = dict.value(forKey: "id") as! NSInteger
        text = dict.value(forKey: "text") as? String
        let unixTimestamp = dict.value(forKey: "date") as! NSNumber
        date = Date(timeIntervalSince1970: unixTimestamp.doubleValue)
        if let user = dict.value(forKey: "user") as? NSDictionary, let first = user.value(forKey: "firstname") as? String,
                let last = user.value(forKey: "lastname") as? String {
            name = first + " " + last
            if let profilePicDict = user.value(forKey: "profilePic") as? NSDictionary {
                BOImage.createFromDictionary(profilePicDict) { (image) in
                    self.profilePic = image
                    self.save()
                }
            }
        }
        flagNeedsUpload = false
        self.save()
    }
    
    func save() {
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func upload() {
        var dict = [String:AnyObject]()
        dict["text"] = self.text as AnyObject?
        dict["date"] = date.timeIntervalSince1970 as AnyObject?
        BONetworkManager.doJSONRequestPOST(.PostComment, arguments: [postID], parameters: dict, auth: true, success: { (response) in
            // Tracking
            self.flagNeedsUpload = false
            self.save()
            Flurry.logEvent("/posting/comment/upload/completed_successful")
        }) { (error, response) in
            Flurry.logEvent("/posting/comment/upload/completed_error")
        }
    }
    
    func printToLog() {
        print("----------- BOComment -----------")
        print("ID: ", self.uuid)
        print("Text: ", self.text)
        print("----------- ------ -----------")
    }
}
