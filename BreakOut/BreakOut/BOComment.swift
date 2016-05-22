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
    @NSManaged var date: NSDate
    @NSManaged var flagNeedsUpload: Bool
    @NSManaged var profilePic: BOImage?
    
    
    class func create(uuid: Int, text: String?, postID: NSInteger) -> BOComment {
        let res = BOComment.MR_createEntity()! as BOComment
        res.uuid = uuid as NSInteger
        res.date = NSDate()
        res.text = text
        res.postID = postID
        res.flagNeedsUpload = true
        if let first = CurrentUser.sharedInstance.firstname, last = CurrentUser.sharedInstance.lastname {
            res.name = first + " " + last
        }
        BOSynchronizeController.sharedInstance.triggerUpload()
        
        // Save
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        return res;
    }
    
    class func createWithDictionary(dict: NSDictionary) -> BOComment {
        let res: BOComment
        if let id = dict["id"] as? NSInteger,
            origPostArray = BOComment.MR_findByAttribute("uuid", withValue: id) as? Array<BOComment>,
            post = origPostArray.first {
            res = post
        } else {
            res = BOComment.MR_createEntity()!
        }
        res.setAttributesWithDictionary(dict)
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        return res
    }
    
    func setAttributesWithDictionary(dict: NSDictionary) {
        uuid = dict.valueForKey("id") as! NSInteger
        text = dict.valueForKey("text") as? String
        let unixTimestamp = dict.valueForKey("date") as! NSNumber
        date = NSDate(timeIntervalSince1970: unixTimestamp.doubleValue)
        if let user = dict.valueForKey("user") as? NSDictionary, first = user.valueForKey("firstname") as? String,
                last = user.valueForKey("lastname") as? String {
            name = first + " " + last
            if let profilePicDict = user.valueForKey("profilePic") as? NSDictionary {
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
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
    
    func upload() {
        var dict = [String:AnyObject]()
        dict["text"] = self.text
        dict["date"] = date.timeIntervalSince1970
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