//
//  BOCommentSyncManager.swift
//  BreakOut
//
//  Created by Mathias Quintero on 9/26/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation
class BOCommentSyncManager: BOSyncManager {
    
    required init() { }
    
    func uploadMissing() {
        if let commentsToUpload = BOComment.mr_find(byAttribute: "flagNeedsUpload", withValue: true) as? Array<BOComment> {
            for comment in commentsToUpload {
                comment.upload()
            }
        }
    }
    
    func dowloadMisisng() { }
    
    
    
}
