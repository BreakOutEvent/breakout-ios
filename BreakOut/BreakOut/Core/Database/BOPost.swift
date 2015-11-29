//
//  BOPost.swift
//  BreakOut
//
//  Created by Leo Käßner on 28.11.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import Foundation

import MagicalRecord

@objc(BOPost)
class BOPost: NSManagedObject {
    @NSManaged var uuid: String?
    @NSManaged var name: String?
    
    class func create(uuid: NSString, name: NSString) {
        let res = BOPost.MR_createEntity() as BOPost
        
        res.uuid = uuid as String
        res.name = name as String
        // Save
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        //return res;
    }
}