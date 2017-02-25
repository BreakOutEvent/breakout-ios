//
//  BONetworkManager.swift
//  
//
//  Created by Mathias Quintero on 5/3/16.
//
//

import Foundation
import AFOAuth2Manager
import Alamofire
import Flurry_iOS_SDK
import Crashlytics

import Sweeft

// TODO: Remove all request code from here and rename this to LoginManager
// TODO: We'll also need an upload manager

enum LoginManager {
    
    static var auth: Auth {
        return AFOAuthCredential.retrieveCredential(withIdentifier: loginStorage) ?? NoAuth.standard
    }
    
    fileprivate static let loginSecret = "123456789"
    
    fileprivate static let loginStorage = "apiCredentials"
    
    static func login(_ user: String, pass: String, success: @escaping () -> (), error: @escaping () -> ()) {
        if let url = URL(string: PrivateConstants().backendURL()) {
            let oAuthManager: AFOAuth2Manager = AFOAuth2Manager.init(baseURL: url,
                                                                     clientID: "breakout_app", secret: PrivateConstants().oAuthSecret())
            oAuthManager
                .authenticateUsingOAuth(withURLString: "/oauth/token", username: user, password: pass, scope: "read write", success: { (credentials) -> Void in
                    BOToast.log("Login was successful.")
                    print("LOGIN: OAuth Code: " + credentials.accessToken)
                    if AFOAuthCredential.store(credentials, withIdentifier: loginStorage) {
                        success()
                    } else {
                        BOToast.log("ERROR: During storing the OAuth credentials.", level: .error)
                        
                        //Tracking
                        Flurry.logEvent("/login/storeCredentials_error")
                        Answers.logCustomEvent(withName: "/login/storeCredentials_error", customAttributes: [:])
                    }
                }) { (Error: Error!) -> Void in
                    print("LOGIN: Error: ")
                    print(Error)
                    BOToast.log("ERROR: During Login", level: .error)
                    // Tracking
                    Flurry.logEvent("/login/completed_error")
                    Answers.logLogin(withMethod: "e-mail", success: false, customAttributes: [:])
                    error()
            }
        }
    }
    
}
