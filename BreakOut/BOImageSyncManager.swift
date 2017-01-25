//
//  BOImageSyncManager.swift
//  BreakOut
//
//  Created by Mathias Quintero on 9/26/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation
import Sweeft

class BOImageSyncManager: BOSyncManager {
    
    required init() { }
    
    func uploadMissing() {
//        if (CurrentUser.shared.isLoggedIn() && CurrentUser.shared.currentTeamId() >= 0 && CurrentUser.shared.currentEventId() >= 0) {
//            (BOMedia.all { $0.flagNeedsUpload }) => BOMedia.upload
//        } else {
//            print("Can't upload location -- User is not logged in and not in a team")
//        }
    }
    
    func dowloadMisisng() {
//        (BOMedia.all { $0.needsBetterDownload }) => { BOImageDownloadManager.shared.getBetterImage($0.uuid) }
    }
    
}
