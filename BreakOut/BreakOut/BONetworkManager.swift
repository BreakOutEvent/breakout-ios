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

class BONetworkManager {
    
    private static let loginSecret = "123456789"
    
    private static let loginStorage = "apiCredentials"
    
    private enum HTTPMethod {
        case GET, PUT, POST, DELETE
        func requestType(requestManager: AFHTTPSessionManager) -> (String, parameters: AnyObject?, success: ((NSURLSessionDataTask, AnyObject?) -> Void)?, failure: ((NSURLSessionDataTask?, NSError) -> Void)?) -> NSURLSessionDataTask? {
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
        
        let requestManager = AFHTTPSessionManager.init(baseURL: NSURL(string: PrivateConstants().backendURL()))
        requestManager.requestSerializer = AFJSONRequestSerializer()
        if auth {
            let credentials = AFOAuthCredential.retrieveCredentialWithIdentifier(loginStorage)
            requestManager.requestSerializer
                .setAuthorizationHeaderFieldWithCredential(credentials)
        }
        let requestString = String(format: service.rawValue, arguments: arguments)
        method.requestType(requestManager)(requestString, parameters: parameters, success: {
            (operation, response) -> Void in
            print("✅Successful: : \n Request: \(requestString) \n methode: \(method) \n with Parms: \(parameters) \n \(requestString) Response: ")
            print(response)
            if let unwrappedResponse = response {
                 handler(unwrappedResponse)
            }
            BOToast.log("SUCCESSFUL (): \(requestString) Download! w. Parms \(parameters)")
        }) { (operation, err) -> Void in
            print("❗️ERROR: \n Request: \(requestString) \n methode: \(method) \n with Parms: \(parameters)")
            print(err)
            BOToast.log("ERROR: during \(requestString)", level: .Error)
            if let errHandler = error {
                if let response = operation?.response as? NSHTTPURLResponse {
                    errHandler(err, response)
                } else {
                    errHandler(err, nil)
                }
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
        if let url = NSURL(string: PrivateConstants().backendURL()) {
            let oAuthManager: AFOAuth2Manager = AFOAuth2Manager.init(baseURL: url,
                                                                     clientID: "breakout_app", secret: PrivateConstants().oAuthSecret())
            oAuthManager
                .authenticateUsingOAuthWithURLString("/oauth/token", username: user, password: pass, scope: "read write", success: { (credentials) -> Void in
                    BOToast.log("Login was successful.")
                    print("LOGIN: OAuth Code: "+credentials.accessToken)
                    if AFOAuthCredential.storeCredential(credentials, withIdentifier: loginStorage) {
                        success()
                    } else {
                        BOToast.log("ERROR: During storing the OAuth credentials.", level: .Error)
                        
                        //Tracking
                        Flurry.logEvent("/login/storeCredentials_error")
                        Answers.logCustomEventWithName("/login/storeCredentials_error", customAttributes: [:])
                    }
                }) { (nserror: NSError!) -> Void in
                    print("LOGIN: Error: ")
                    print(nserror)
                    BOToast.log("ERROR: During Login", level: .Error)
                    // Tracking
                    Flurry.logEvent("/login/completed_error")
                    Answers.logLoginWithMethod("e-mail", success: false, customAttributes: [:])
                    error()
            }
        }

    }
    
    static func uploadMedia(id: Int, token: String, data: NSData, filename: String, success: () -> (), error: () -> ()) {
        
        Alamofire.upload(.POST, "http://breakout-media.westeurope.cloudapp.azure.com:3001/", headers: ["X-UPLOAD-TOKEN": token], multipartFormData: { multipartFormData in
            multipartFormData.appendBodyPart(data: data, name: "file", fileName: filename, mimeType: "image/jpg")
                if let data = id.description.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    multipartFormData.appendBodyPart(data: data, name: "id")
                }
            }, encodingMemoryThreshold: 10*1024*1024) { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseString() { (response) in
                        if response.result.error != nil {
                            print(response.result.error)
                            error()
                        } else {
                            success()
                            BOToast.log("SUCCESSFUL: Media Upload")
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                    error()
                }
        }
        
        
    }
    
}