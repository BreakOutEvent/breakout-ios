//
//  BreakOutAPI.swift
//  BreakOut
//
//  Created by Mathias Quintero on 1/11/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import UIKit

/// Main Part Of Our API
struct BreakOut: API {
    typealias Endpoint = BreakOutEndpoint
    
    var baseURL: String
    
    /// Shared instance of the API
    static let shared = BreakOut(baseURL: PrivateConstants().backendURL())
}

extension BreakOut {
    
    fileprivate struct BreakOutAuth: OptionalStatus {
        typealias Value = OAuth
        static var key: AppDefaults = .login
    }
    
    /// Current Authentication
    var auth: Auth {
        get {
            let oauth = BreakOutAuth.value
            oauth?.delegate = self
            return oauth ?? NoAuth.standard
        }
    }
    
    /**
     Will Login using OAuth and store it for persistance.
     It can later be accessed from .auth or as the result of the Promise
     
     - Parameter email: email of the user
     - Parameter password: password of the user
     
     - Returns: Promise of the Auth Object
     */
    func login(email: String, password: String) -> OAuth.Result {
        let manager = self.oauthManager(clientID: "breakout_app", secret: PrivateConstants().oAuthSecret())
        return manager.authenticate(at: .login, username: email, password: password, scope: "read", "write").nested { (auth: OAuth) in
            BreakOutAuth.value = auth
            return auth
        }
    }
    
}

extension BreakOut: OAuthDelegate {
    
    func didRefresh(replace old: OAuth, with new: OAuth) {
        BreakOutAuth.value = new
    }
    
}
