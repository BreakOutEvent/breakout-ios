//
//  BONetworkManager.swift
//  
//
//  Created by Mathias Quintero on 5/3/16.
//
//

import Foundation
import AFOAuth2Manager

class BONetworkManager {
    
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
            requestManager.requestSerializer
                .setAuthorizationHeaderFieldWithCredential(AFOAuthCredential.retrieveCredentialWithIdentifier("apiCredentials") )
        }
        method.requestType(requestManager)(String(format: service.rawValue, arguments: arguments), parameters: parameters, success: {
            (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            print("\(service.rawValue) Response: ")
            print(response)
            handler(response)
            BOToast.log("SUCCESSFUL: \(service.rawValue) Download! w. Args \(arguments)")
        }) { (operation: AFHTTPRequestOperation?, err: NSError) -> Void in
            print("ERROR: while \(service.rawValue) w. Args \(arguments)")
            print(err)
            BOToast.log("ERROR: during \(service.rawValue)", level: .Error)
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
    
}