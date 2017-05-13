//
//  BreakOutAPI.swift
//  BreakOut
//
//  Created by Mathias Quintero on 1/11/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import OneSignal
import UIKit

/// Main Part Of Our API
class BreakOut: API {
    
    typealias Endpoint = BreakOutEndpoint
    
    var baseURL: String
    
    /// Current Authentication
    lazy var auth: Auth = {
        var oauth = BreakOutAuth.value
        oauth?.onChange { oauth in
            BreakOutAuth.value = oauth
        }
        return oauth ?? NoAuth.standard
    }()
    
    /// Shared instance of the API
    static var shared: BreakOut = {
        return BreakOut(baseURL: PrivateConstants().backendURL())
    }()
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
}

extension BreakOut {
    
    fileprivate struct BreakOutAuth: OptionalStatus {
        typealias Value = OAuth
        static var storage: Storage = .keychain
        static var key: AppDefaults = .login
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
            self.auth = auth
            if let token = OneSignal.token {
                self.sendNotificationToken(token: token)
            }
            return auth
        }
    }
    
    @discardableResult func sendNotificationToken(token: String, for user: CurrentUser = .shared) -> JSON.Result {
        return doJSONRequest(with: .put, to: .notificationToken, arguments: ["id": user.id], auth: auth, body: [
                "token": token,
            ])
    }
    
    @discardableResult func removeNotificationToken(for user: CurrentUser = .shared) -> JSON.Result {
        return doJSONRequest(with: .delete, to: .notificationToken, arguments: ["id": user.id], auth: auth)
    }
    
    /**
     Will erase any persisted login data
     */
    func logout() {
        removeNotificationToken()
        BreakOutAuth.value = nil
        auth = NoAuth.standard
    }
    
}
