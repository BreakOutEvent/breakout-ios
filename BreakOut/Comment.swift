//
//  Comment.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

/// Comment on a posting
struct Comment {
    let date: Date
    let text: String?
    let participant: Participant
}

extension Comment: Deserializable {
    
    init?(from json: JSON) {
        guard let date = json["date"].date(),
              let participant = json["user"].participant else {
                
                return nil
        }
        self.init(date: date, text: json["text"].string, participant: participant)
    }
    
}

extension Comment: ObservableContainer {
    
    var observable: Participant {
        return participant
    }
    
}
