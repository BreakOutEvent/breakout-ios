//
//  Event.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

struct Event {
    let id: Int
    let title: String
    let city: String
    let date: Date
}

extension Event: Deserializable {
    
    public init?(from json: JSON) {
        guard let id = json["id"].int,
            let title = json["title"].string,
            let city = json["city"].string,
            let date = json["date"].date() else {
                
                return nil
        }
        self.init(id: id, title: title, city: city, date: date)
    }
    
}

extension Event {
    
    static func all(using api: BreakOut = .shared) -> Event.Results {
        return getAll(using: api, at: .event)
    }
    
}
