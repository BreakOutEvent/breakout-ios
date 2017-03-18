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
    
    /**
     Register a user as a Participant and set the info to the Current User
     
     - Parameter firstName: first name
     - Parameter lastName: last name
     - Parameter gender: gender
     - Parameter email: email address
     - Parameter emergencyNumber: emergency contact phone number
     - Parameter phone: phone number
     - Parameter shirtSize: size of the t-shirt for the user
     - Parameter api: Break Out backend
     
     - Returns: Promise of the JSON
     */
    static func become(firstName: String,
                       lastName: String,
                       gender: String,
                       email: String,
                       emergencyNumber: String,
                       phone: String,
                       shirtSize: String,
                       using api: BreakOut = .shared) -> JSON.Result {
        
        let body: JSON = [
            "firstname": firstName,
            "lastname": lastName,
            "email": email,
            "gender": gender,
            "participant": [
                "emergencynumber": emergencyNumber,
                "phonenumber": phone,
                "tshirtsize": shirtSize
            ].json
        ]
        let promise = api.doJSONRequest(with: .post, to: .userData, auth: api.auth, body: body, acceptableStatusCodes: [200, 201])
        promise.onSuccess(call: CurrentUser.shared.set)
        return promise
    }
    
}
