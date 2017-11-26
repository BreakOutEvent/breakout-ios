//
//  BreakOutAPI.swift
//  BreakOut
//
//  Created by Mathias Quintero on 1/11/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import UIKit

class BreakOut: OAuthAPI<BreakOutEndpoint, AppDefaults> {
    
    static var shared: BreakOut = {
        return .init(baseURL: PrivateConstants().backendURL())
    }()
    
    init(baseURL: String) {
        super.init(baseURL: baseURL,
                   storage: .keychain,
                   tokenKey: .login,
                   authEndpoint: .login,
                   clientID: "breakout_app",
                   clientSecret: PrivateConstants().oAuthSecret(),
                   useBasicHttp: true,
                   useJSON: false)
    }
    
    /**
     Will erase any persisted login data
     */
    override func logout() {
        if CurrentUser.shared.isLoggedIn() {
            removeNotificationToken()
        }
        super.logout()
    }
    
}

extension BreakOut {
    
    /**
     Will Login using OAuth and store it for persistance.
     It can later be accessed from .auth or as the result of the Promise
     
     - Parameter email: email of the user
     - Parameter password: password of the user
     
     - Returns: Promise of the Auth Object
     */
    func login(email: String, password: String) -> Response<OAuth> {
        return authenticate(username: email,
                            password: password,
                            scope: "read", "write")
    }
    
    @discardableResult func sendNotificationToken(token: String, for user: CurrentUser = .shared) -> JSON.Result {
        return doJSONRequest(with: .put, to: .notificationToken, arguments: ["id": user.id], auth: auth, body: [
                "token": token,
            ])
    }
    
    @discardableResult func removeNotificationToken(for user: CurrentUser = .shared) -> JSON.Result {
        return doJSONRequest(with: .delete, to: .notificationToken, arguments: ["id": user.id], auth: auth)
    }
    
}
