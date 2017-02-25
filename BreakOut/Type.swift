//
//  Type.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

enum Type: String {
    case image = "IMAGE"
    case video = "VIDEO"
    case none = "NONE"
}

extension Type: Deserializable {
    
    public init?(from json: JSON) {
        guard let item = json.string | Type.init(rawValue:) ?? nil else {
            self = .none
            return
        }
        self = item
    }
    
}
