//
//  BOTeam.swift
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

@objc(BOTeam)
class BOTeam: NSManagedObject {
    
    @NSManaged var uuid: NSInteger
    @NSManaged var text: String?
    @NSManaged var flagNeedsDownload: Bool
    @NSManaged var name: String?
    @NSManaged var profilePic: BOImage?
    
    class func create(uuid: Int, flagNeedsDownload: Bool) -> BOTeam {
        if let origTeamArray = BOPost.MR_findByAttribute("uuid", withValue: uuid) as? Array<BOTeam>, team = origTeamArray.first {
            team.flagNeedsDownload = false
            return team
        }
        
        let res = BOTeam.MR_createEntity()! as BOTeam
        res.uuid = uuid as NSInteger
        res.flagNeedsDownload = flagNeedsDownload
        
        // Save
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        return res;
    }
    
    class func createWithDictionary(dict: NSDictionary) -> BOTeam {
        let res: BOTeam
        if let id = dict["id"] as? NSInteger,
            origTeamArray = BOTeam.MR_findByAttribute("uuid", withValue: id) as? Array<BOTeam>,
            team = origTeamArray.first {
            res = team
        } else {
            res = BOTeam.MR_createEntity()!
        }
        
        res.setAttributesWithDictionary(dict)
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        
        return res
    }
    
    func setAttributesWithDictionary(dict: NSDictionary) {
        uuid = dict.valueForKey("id") as! NSInteger
        text = dict.valueForKey("description") as? String
        name = dict.valueForKey("name") as? String
        if let profilePicDict = dict.valueForKey("profilePic") as? NSDictionary {
            BOImage.createFromDictionary(profilePicDict) { (image) in
                self.profilePic = image
                self.save()
            }
        }
        self.save()
    }
    
    func save() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
    
    func printToLog() {
        print("----------- BOTeam -----------")
        print("ID: ", self.uuid)
        print("Text: ", self.text)
        print("flagNeedsDownload: ", self.flagNeedsDownload)
        print("----------- ------ -----------")
    }
}