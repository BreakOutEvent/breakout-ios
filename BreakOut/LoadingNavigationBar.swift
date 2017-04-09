//
//  LoadingNavigationBar.swift
//  BreakOut
//
//  Created by Mathias Quintero on 4/9/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit

var activityIndicator = UIActivityIndicatorView()
var previousText: String = .empty

extension UINavigationBar {
    
    func startSpining() {
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.color = .white
        previousText = self.topItem?.title ?? ""
        self.topItem?.title = ""
        let side = frame.height - 2
        let x = (frame.width - side - 2)/2
        activityIndicator.frame = CGRect(x: x, y: 1, width: side, height: side)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        layoutIfNeeded()
    }
    
    func stopSpinning() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        topItem?.title = previousText
    }
    
}
