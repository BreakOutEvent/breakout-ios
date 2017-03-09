//
//  Team.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

/// Representation of a team
struct Team {
    let id: Int
    let name: String
}

extension Team: Deserializable {
    
    public init?(from json: JSON) {
        guard let id = json["teamId"].int ?? json["id"].int, let name = json["teamName"].string ?? json["name"].string else {
            return nil
        }
        self.init(id: id, name: name)
    }
    
}

extension Team {
    
    /**
     Invite someone to your team
     
     - Parameter name: name of the person
     - Parameter event: id of the event
     - Parameter api: Break Out backend
     
     - Returns: Promise of the locations
     */
    func invite(name: String, to event: Int, using api: BreakOut = .shared) -> JSON.Result {
        let body: JSON = [
            "event": event.json,
            "name": name.json
        ]
        return api.doJSONRequest(with: .post,
                                 to: .eventInvitation,
                                 arguments: ["event": event, "team": id],
                                 auth: api.auth,
                                 body: body,
                                 acceptableStatusCodes: [200, 201])
    }
    
}

extension Team {
    
    /**
     Fetch all the teams in an event
     
     - Parameter event: id of the event
     - Parameter api: Break Out backend
     
     - Returns: Promise of the teams
     */
    static func all(for event: Int, using api: BreakOut = .shared) -> Team.Results {
        return getAll(using: api, method: .get, at: .eventTeam, arguments: ["event": event])
    }
    
    /**
     Register a team
     
     - Parameter name: name of the team
     - Parameter event: id of the event
     - Parameter image: profile picture of the team
     - Parameter api: Break Out backend
     
     - Returns: Promise of the generated Team
     */
    static func create(name: String, event: Int, image: UIImage?, using api: BreakOut = .shared) -> Team.Result {
        let body: JSON = [
            "event": event.json,
            "name": name.json
        ]
        let promise = api.doJSONRequest(with: .post, to: .eventTeam, arguments: ["event": event], auth: api.auth, body: body, acceptableStatusCodes: [200, 201])
        promise.onSuccess { json in
            
            if let token = json["profilePic"]["uploadToken"].string,
                let id = json["profilePic"]["id"].int {
                
                image?.upload(itemWith: id, using: token)
            }
        }
        return promise.nested { json, promise in
            if let team = json.team {
                CurrentUser.shared.teamid = team.id
                CurrentUser.shared.storeInNSUserDefaults()
                promise.success(with: team)
            } else {
                promise.error(with: .mappingError(json: json))
            }
        }
    }
    
}
