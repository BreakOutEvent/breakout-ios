//
//  UploadManager.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Alamofire

enum UploadManager {
    
    static func upload(data: Data, id: Int, token: String, filename: String, type: String) {
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "file", fileName: filename, mimeType: type)
            if let data = id.description.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                multipartFormData.append(data, withName: "id")
            }
        }, usingThreshold: 10*1024*1024, to: "https://media.break-out.org/", method: .post, headers: ["X-UPLOAD-TOKEN": token]) { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseString() { (response) in
                    if response.result.error != nil {
                        // TODO: Find a way to queue it again
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                // Queue it again here
            }
        }
    }
    
}
