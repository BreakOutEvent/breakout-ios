//
//  BOSyncManager.swift
//  BreakOut
//
//  Created by Mathias Quintero on 9/26/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation
protocol BOSyncManager: class {
    func uploadMissing()
    func dowloadMisisng()
    init()
}

extension BOSyncManager {
    
    func fullSync() {
        uploadMissing()
        dowloadMisisng()
    }
    
}
