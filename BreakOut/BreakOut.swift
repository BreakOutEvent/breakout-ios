//
//  BreakOutAPI.swift
//  BreakOut
//
//  Created by Mathias Quintero on 1/11/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import UIKit

struct BreakOut: API {
    typealias Endpoint = BOEndpoint
    
    var baseURL: String
    
    static var shared = BreakOut()
}

extension BreakOut {
    
    struct BreakOutAuth: OptionalStatus {
        typealias Value = OAuth
        static var key: AppDefaults = .login
    }
    
    var auth: Auth {
        get {
            return BreakOutAuth.value ?? NoAuth.standard
        }
    }
    
    func login(email: String, password: String) -> OAuth.Result {
        let manager = self.oauthManager(clientID: "breakout_app", secret: PrivateConstants().oAuthSecret())
        return manager.authenticate(at: .login, username: email, password: password, scope: "read", "write").nested { (auth: OAuth) in
            BreakOutAuth.value = auth
            return auth
        }
    }
    
    func refreshToken() -> OAuth.Result {
        guard let auth = self.auth as? OAuth else {
            let promise = Promise<OAuth, APIError>()
            promise.error(with: .noData)
            return promise
        }
        let manager = self.oauthManager(clientID: "breakout_app", secret: PrivateConstants().oAuthSecret())
        return manager.refresh(at: .login, with: auth)
    }
    
}

extension BreakOut {
    
    init() {
        self.init(baseURL: PrivateConstants().backendURL())
    }
    
}

extension UIImage {
    
    func upload(itemWith id: Int, using token: String) {
        guard let data = UIImageJPEGRepresentation(self, 0.75) else {
            return
        }
        UploadManager.upload(data: data, id: id, token: token, filename: "Image.jpg", type: "image/jpg")
    }
    
}

extension URL {
    
    func uploadVideo(with id: Int, using token: String) {
        guard let data = try? Data(contentsOf: self) else {
            return
        }
        UploadManager.upload(data: data, id: id, token: token, filename: "Video.mp4", type: "video/mp4")
    }
    
}
