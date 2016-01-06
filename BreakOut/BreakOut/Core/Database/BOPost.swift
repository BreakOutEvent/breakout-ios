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
    @NSManaged var uuid: String?
    @NSManaged var name: String?
    @NSManaged var flagNeedsUpload: Bool
    
    class func create(uuid: NSString, name: NSString) {
        let res = BOPost.MR_createEntity() as BOPost
        
        res.uuid = uuid as String
        res.name = name as String
        // Save
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        //return res;
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