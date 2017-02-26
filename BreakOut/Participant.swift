//
//  Participant.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

final class Participant: Observable {
    
    var listeners = [Listener]()
    let id: Int
    let name: String
    let team: Team?
    let image: Image?
    
    init(id: Int, name: String, team: Team?, image: Image?) {
        self.id = id
        self.name = name
        self.team = team
        self.image = image
        image >>> **self.hasChanged
    }
    
}

extension Participant: Deserializable {
    
    public convenience init?(from json: JSON) {
        guard let id = json["id"].int,
            let first = json["firstname"].string,
            let last = json["lastname"].string else {
                
                return nil
        }
        self.init(id: id, name: "\(first) \(last)", team: json["participant"].team, image: json.profilePic)
    }
    
}

extension Participant {
    
    static func become(firstName: String,
                       lastName: String,
                       gender: String,
                       email: String,
                       emergencyNumber: String,
                       phone: String,
                       shirtSize: String,
                       using api: BreakOut = .shared) -> JSON.Result {
        
        let body: JSON = [
            "firstname": firstName.json,
            "lastname": lastName.json,
            "email": email.json,
            "gender": gender.json,
            "participant": [
                "emergencynumber": emergencyNumber.json,
                "phonenumber": phone.json,
                "tshirtsize": shirtSize.json
            ]
        ]
        let promise = api.doJSONRequest(with: .post, to: .userData, auth: LoginManager.auth, body: body, acceptableStatusCodes: [200, 201])
        promise.onSuccess(call: CurrentUser.shared.set)
        return promise
    }
    
}
