//
//  BODataController.swift
//  BreakOut
//
//  Created by Leo Käßner on 29.11.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import Foundation

/**
 The BODataController is the interface between UI and Database. The UI will ask for single Objects or Lists which the BODataController will query from CoreData. 
 This class can also trigger the BOSynchronizeController to do a new synchronization with the online Backend.
 */
class BODataController: NSObject {
    
    func listOfAllPosts() -> Array<BOPost> {
        return BOPost.MR_findAll()
    }

}