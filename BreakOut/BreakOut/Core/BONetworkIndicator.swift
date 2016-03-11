//
//  BONetworkIndicator.swift
//  BreakOut
//
//  Created by Leo Käßner on 11.03.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

class BONetworkIndicator: NSObject {
    
    var loadingCount: Int = 0
    
    static let si = BONetworkIndicator()
    
    func increaseLoading() {
        self.loadingCount++
        self.handleActivityIndicator()
    }
    
    func decreaseLoading() {
        self.loadingCount--
        self.handleActivityIndicator()
    }
    
    func handleActivityIndicator() {
        if self.loadingCount > 0 {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }else{
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.loadingCount = 0
        }
    }

}
