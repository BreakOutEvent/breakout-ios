//
//  BONetworkManager.swift
//  
//
//  Created by Mathias Quintero on 5/3/16.
//
//

import Foundation
import AFOAuth2Manager
import Flurry_iOS_SDK

class BONetworkManager {
    
    private static let loginSecret = "123456789"
    
    private static let loginStorage = "apiCredentials"
    
    private enum HTTPMethod {
        case GET, PUT, POST, DELETE
        func requestType(requestManager: AFHTTPRequestOperationManager ) -> (String, parameters: AnyObject?, success: ((AFHTTPRequestOperation, AnyObject) -> Void)?, failure: ((AFHTTPRequestOperation?, NSError) -> Void)?) -> AFHTTPRequestOperation? {
            switch self {
            case .GET:
                return requestManager.GET
            case .POST:
                return requestManager.POST
            case .PUT:
                return requestManager.PUT
            case .DELETE:
                return requestManager.DELETE
            }
        }
    }
    
    private static func doJSONRequest(service: BackendServices, arguments: [CVarArgType], parameters: AnyObject?, auth: Bool, handler: (AnyObject) -> (), error: ((NSError, NSHTTPURLResponse?) -> ())?, method: HTTPMethod) {
        let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL(string: PrivateConstants.backendURL))
        requestManager.requestSerializer = AFJSONRequestSerializer()
        if auth {
            let credentials = AFOAuthCredential.retrieveCredentialWithIdentifier(loginStorage)
            requestManager.requestSerializer
                .setAuthorizationHeaderFieldWithCredential(credentials)
        }
        let requestString = String(format: service.rawValue, arguments: arguments)
        method.requestType(requestManager)(requestString, parameters: parameters, success: {
            (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            print("\(requestString) Response: ")
            print(response)
            
            handler(response)
            BOToast.log("SUCCESSFUL: \(requestString) Download! w. Parms \(parameters)")
        }) { (operation: AFHTTPRequestOperation?, err: NSError) -> Void in
            print("ERROR: while \(requestString) w. Parms \(parameters)")
            print(err)
            BOToast.log("ERROR: during \(requestString)", level: .Error)
            if let errHandler = error {
                errHandler(err, operation?.response)
            }
        }
    }
    
    static func doJSONRequestGET(service: BackendServices, arguments: [CVarArgType], parameters: AnyObject?, auth: Bool, success: (AnyObject) -> ()) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: nil, method: .GET)
    }
    
    static func doJSONRequestPOST(service: BackendServices, arguments: [CVarArgType], parameters: AnyObject?, auth: Bool, success: (AnyObject) -> ()) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: nil, method: .POST)
    }
    
    static func doJSONRequestPUT(service: BackendServices, arguments: [CVarArgType], parameters: AnyObject?, auth: Bool, success: (AnyObject) -> ()) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: nil, method: .PUT)
    }
    
    static func doJSONRequestDELETE(service: BackendServices, arguments: [CVarArgType], parameters: AnyObject?, auth: Bool, success: (AnyObject) -> ()) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: nil, method: .DELETE)
    }
    
    static func doJSONRequestGET(service: BackendServices, arguments: [CVarArgType], parameters: AnyObject?, auth: Bool, success: (AnyObject) -> (), error: ((NSError, NSHTTPURLResponse?) -> ())?) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .GET)
    }
    
    static func doJSONRequestPUT(service: BackendServices, arguments: [CVarArgType], parameters: AnyObject?, auth: Bool, success: (AnyObject) -> (), error: ((NSError, NSHTTPURLResponse?) -> ())?) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .PUT)
    }
    
    static func doJSONRequestPOST(service: BackendServices, arguments: [CVarArgType], parameters: AnyObject?, auth: Bool, success: (AnyObject) -> (), error: ((NSError, NSHTTPURLResponse?) -> ())?) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .POST)
    }
    
    static func doJSONRequestDELETE(service: BackendServices, arguments: [CVarArgType], parameters: AnyObject?, auth: Bool, success: (AnyObject) -> (), error: ((NSError, NSHTTPURLResponse?) -> ())?) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .DELETE)
    }
    
    static func loginRequest(user: String, pass: String, success: () -> (), error: () -> ()) {
        let oAuthManager: AFOAuth2Manager = AFOAuth2Manager.init(baseURL: NSURL(string: PrivateConstants.backendURL),
                                                                 clientID: "breakout_app", secret: loginSecret)
        oAuthManager
            .authenticateUsingOAuthWithURLString("/oauth/token", username: user, password: pass, scope: "read write", success: { (credentials) -> Void in
                BOToast.log("Login was successful.")
                print("LOGIN: OAuth Code: "+credentials.accessToken)
                if AFOAuthCredential.storeCredential(credentials, withIdentifier: loginStorage) {
                   success()
                } else {
                   BOToast.log("ERROR: During storing the OAuth credentials.", level: .Error)
                }
        }) { (error: NSError!) -> Void in
            print("LOGIN: Error: ")
            print(error)
            BOToast.log("ERROR: During Login", level: .Error)
            // Tracking
            Flurry.logEvent("/login/completed_error")
        }

    }
    
}