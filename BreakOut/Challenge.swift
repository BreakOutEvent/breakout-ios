//
//  Challenge.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

/// Challenge on a Posting
struct Challenge {
    let id: Int
    let text: String?
    let status: String?
    let amount: Int?
}

extension Challenge: Deserializable {
    
    public init?(from json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }
        self.init(id: id, text: json["description"].string, status: json["status"].string, amount: json["amount"].int)
    }
    
}

extension Challenge {
    
    /**
     Fetch the Challenges for a team
     
     - Parameter event: id of the event
     - Parameter team: id of the team
     - Parameter api: Break Out backend
     
     - Returns: Promise of the JSON
     */
    static func get(event: Int, team: Int, using api: BreakOut = .shared) -> Challenge.Results {
        return getAll(using: api, method: .get, at: .eventTeamChallenge, arguments: ["event": event, "team": team], auth: api.auth)
    }
    
}
