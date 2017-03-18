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
    
    enum Status: String {
        case proposed = "PROPOSED"
        case accepted = "ACCEPTED"
        case proven = "WITH_PROOF"
    }
    
    let id: Int
    let text: String?
    let status: Status?
    let amount: Double?
    
    var completed: Bool {
        return status == .proven
    }
}

extension Challenge.Status: Deserializable {
    
    public init?(from json: JSON) {
        guard let value = json.string else {
            return nil
        }
        self.init(rawValue: value)
    }
    
}

extension Challenge: Deserializable {
    
    public init?(from json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }
        self.init(id: id, text: json["description"].string, status: json["status"].challengeStatus, amount: json["amount"].double)
    }
    
}

extension Challenge {
    
    /**
     Set the Status related to a posting
     
     - Parameter status: New Status
     - Parameter post: post that is related to the challenge
     - Parameter api: Break Out backend
     
     - Returns: Promise of the JSON
     */
    @discardableResult func set(status: Status, for post: Post, using api: BreakOut = .shared) -> Challenge.Result {
        guard let team = post.participant.team?.id, let event = post.participant.team?.event else {
            return .errored(with: .cannotPerformRequest)
        }
        let body: JSON = [
            "postingId": post.id,
            "status": status.rawValue,
        ]
        return api.doObjectRequest(with: .put,
                                   to: .challengeStatus,
                                   arguments: ["event": event, "team": team, "challenge": id],
                                   auth: api.auth,
                                   body: body)
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
