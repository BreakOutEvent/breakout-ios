//
//  GenderAPI.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/27/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

fileprivate enum GenderEndpoint: String, APIEndpoint {
    case standard = ""
}

fileprivate struct GenderAPI: API {
    
    typealias Endpoint = GenderEndpoint
    
    var baseURL: String
    
    static var shared = GenderAPI(baseURL: "https://api.genderize.io/")
    
}

enum Gender: String {
    case male = "male"
    case female = "female"
}

extension Gender: Deserializable {
    
    init?(from json: JSON) {
        guard let gender = json["gender"].string else {
            return nil
        }
        self.init(rawValue: gender)
    }
    
}

extension Gender {
    
    /**
     Fetch the gender of a name
     
     - Parameter name: Name of the person
     
     - Returns: Promise of the guessed gender
     */
    static func gender(for name: String) -> Gender.Result {
        return get(using: GenderAPI.shared, at: .standard)
    }
    
}
