//
//  BOImageSyncManager.swift
//  BreakOut
//
//  Created by Mathias Quintero on 9/26/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation
class BOImageSyncManager: BOSyncManager {
    
    required init() { }
    
    func uploadMissing() {
        if (CurrentUser.shared.isLoggedIn() && CurrentUser.shared.currentTeamId() >= 0 && CurrentUser.shared.currentEventId() >= 0) {
            if let imagesToUpload = BOImage.mr_find(byAttribute: "flagNeedsUpload", withValue: true) as? Array<BOImage> {
                for image in imagesToUpload {
                    image.upload()
                }
            }
        } else {
            print("Can't upload location -- User is not logged in and not in a team")
        }
    }
    
    func dowloadMisisng() {
        if let images = BOImage.mr_find(byAttribute: "needsBetterDownload", withValue: true) as? Array<BOImage> {
            for image in images {
                BOImageDownloadManager.shared.getBetterImage(image.uid)
            }
        }
    }
    
}
