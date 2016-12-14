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
import SwiftyJSON

class BONetworkManager {
    
    typealias SuccessHandler = (JSON) -> ()
    typealias ErrorHandler = (Error, HTTPURLResponse?) -> ()
    typealias BOHandler<T: BOObject> = (T) -> ()
    typealias BOCollectionHandler<T: BOObject> = ([T]) -> ()
    
    fileprivate static let loginSecret = "123456789"
    
    fileprivate static let loginStorage = "apiCredentials"
    
    fileprivate enum HTTPMethod {
        case get, put, post, delete
        func requestType(_ requestManager: AFHTTPSessionManager) -> (String, _ parameters: Any?, _ success: ((URLSessionDataTask, Any?) -> Void)?, _ failure: ((URLSessionDataTask?, Error) -> Void)?) -> URLSessionDataTask? {
            switch self {
            case .get:
                return requestManager.get(_:parameters:success:failure:)
            case .post:
                return requestManager.post(_:parameters:success:failure:)
            case .put:
                return requestManager.put(_:parameters:success:failure:)
            case .delete:
                return requestManager.delete(_:parameters:success:failure:)
            }
        }
    }
    
    fileprivate static func doJSONRequest<T: BOObject>(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, handler: @escaping BOHandler<T>, error: ErrorHandler?, method: HTTPMethod) {
        
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: { (json) in
            
            let object = T.init(from: json)
            object | handler
        }, error: error, method: method)
    }
    
    fileprivate static func doJSONRequest<T: BOObject>(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, handler: @escaping BOCollectionHandler<T>, error: ((Error, HTTPURLResponse?) -> ())?, method: HTTPMethod) {
        
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: { (json) in
            let array = !((json.array ?? []) => T.init)
            array | handler
        }, error: error, method: method)
    }
    
    fileprivate static func doJSONRequest(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, handler: @escaping SuccessHandler, error: ((Error, HTTPURLResponse?) -> ())?, method: HTTPMethod) {
        BONetworkIndicator.si.increaseLoading()
        let requestManager = AFHTTPSessionManager.init(baseURL: URL(string: PrivateConstants().backendURL()))
        requestManager.requestSerializer = AFJSONRequestSerializer()
        if auth {
            let credentials = AFOAuthCredential.retrieveCredential(withIdentifier: loginStorage)
            requestManager.requestSerializer
                .setAuthorizationHeaderFieldWith(credentials)
        }
        let requestString = String(format: service.rawValue, arguments: arguments)
        _ = method.requestType(requestManager)(requestString, parameters, {
            (operation, response) -> Void in
            print("✅Successful: : \n Request: \(requestString) \n methode: \(method) \n with Parms: \(parameters) \n \(requestString) Response: ")
            print(response)
            if let response = response as? [String:Any] {
                let json = JSON(response)
                handler(json)
            }
            BOToast.log("SUCCESSFUL (): \(requestString) Download! w. Parms \(parameters)")
            BONetworkIndicator.si.decreaseLoading()
        }) { (operation, err) -> Void in
            print("❗️ERROR: \n Request: \(requestString) \n methode: \(method) \n with Parms: \(parameters)")
            print(err)
            BOToast.log("ERROR: during \(requestString)", level: .error)
            if let errHandler = error {
                if let response = operation?.response as? HTTPURLResponse {
                    errHandler(err, response)
                } else {
                    errHandler(err, nil)
                }
            }
            BONetworkIndicator.si.decreaseLoading()
        }
    }
    
    static func get(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, success: @escaping SuccessHandler, error: ErrorHandler? = nil) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .get)
    }
    
    static func get<T: BOObject>(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, success: @escaping BOHandler<T>, error: ErrorHandler? = nil) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .get)
    }
    
    static func get<T: BOObject>(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, success: @escaping BOCollectionHandler<T>, error: ErrorHandler? = nil) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .get)
    }
    
    static func put(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, success: @escaping SuccessHandler, error: ErrorHandler? = nil) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .put)
    }
    
    static func put<T: BOObject>(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, success: @escaping BOHandler<T>, error: ErrorHandler? = nil) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .put)
    }
    
    static func put<T: BOObject>(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, success: @escaping BOCollectionHandler<T>, error: ErrorHandler? = nil) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .put)
    }
    
    static func post(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, success: @escaping SuccessHandler, error: ErrorHandler? = nil) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .post)
    }
    
    static func post<T: BOObject>(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, success: @escaping BOHandler<T>, error: ErrorHandler? = nil) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .post)
    }
    
    static func post<T: BOObject>(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, success: @escaping BOCollectionHandler<T>, error: ErrorHandler? = nil) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .post)
    }
    
    static func delete(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, success: @escaping SuccessHandler, error: ErrorHandler? = nil) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .delete)
    }
    
    static func delete<T: BOObject>(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, success: @escaping BOHandler<T>, error: ErrorHandler? = nil) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .delete)
    }
    
    static func delete<T: BOObject>(_ service: BackendServices, arguments: [CVarArg], parameters: Any?, auth: Bool, success: @escaping BOCollectionHandler<T>, error: ErrorHandler? = nil) {
        doJSONRequest(service, arguments: arguments, parameters: parameters, auth: auth, handler: success, error: error, method: .delete)
    }
    
    static func loginRequest(_ user: String, pass: String, success: @escaping () -> (), error: @escaping () -> ()) {
        if let url = URL(string: PrivateConstants().backendURL()) {
            let oAuthManager: AFOAuth2Manager = AFOAuth2Manager.init(baseURL: url,
                                                                     clientID: "breakout_app", secret: PrivateConstants().oAuthSecret())
            oAuthManager
                .authenticateUsingOAuth(withURLString: "/oauth/token", username: user, password: pass, scope: "read write", success: { (credentials) -> Void in
                    BOToast.log("Login was successful.")
                    print("LOGIN: OAuth Code: "+credentials.accessToken)
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
    
    static func uploadMedia(_ id: Int, token: String, data: Data, filename: String, success: @escaping () -> (), error: @escaping () -> ()) {
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "file", fileName: filename, mimeType: "image/jpg")
            if let data = id.description.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                multipartFormData.append(data, withName: "id")
            }
        }, usingThreshold: 10*1024*1024, to: "http://breakout-media.westeurope.cloudapp.azure.com:3001/", method: .post, headers: ["X-UPLOAD-TOKEN": token]) { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseString() { (response) in
                    if response.result.error != nil {
                        print(response.result.error)
                        error()
                    } else {
                        success()
                        BOToast.log("SUCCESSFUL: Media Upload")
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                error()
            }
        }
        
        
    }
    
}
