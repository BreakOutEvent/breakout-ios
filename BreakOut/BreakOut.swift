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
