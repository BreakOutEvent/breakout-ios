//
//  NewPost.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/27/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

/// Helper struct for locally defined postings
struct NewPost {
    let text: String
    let date: Date
    let latitude: Double
    let longitude: Double
    let media: [NewMedia]
}

extension NewPost: Serializable {
    
    var json: JSON {
        return [
            "text": text,
            "date": date.timeIntervalSince1970,
            "postingLocation": [
                "latitude": latitude,
                "longitude": longitude,
            ].json,
            "uploadMediaTypes": (media => { $0.type }).json
        ]
    }
    
}
