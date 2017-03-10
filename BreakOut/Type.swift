//
//  Type.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

/// Type of a media item
enum Type: String {
    case image = "IMAGE"
    case video = "VIDEO"
    case none = "NONE"
}

extension Type: Deserializable {
    
    public init?(from json: JSON) {
        guard let item = json.string else {
            self.init(rawValue: "NONE")
            return
        }
        self.init(rawValue: item)
    }
    
}
