//
//  Message.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/27/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

struct Message {
    let text: String
    let date: Date
    let participant: Int
}

extension Message: Deserializable {
    
    init?(from json: JSON) {
        guard let text = json["text"].string,
            let date = json["date"].date(),
            let participant = json["creator"]["id"].int else {
                
            return nil
        }
        self.init(text: text, date: date, participant: participant)
    }
    
}
