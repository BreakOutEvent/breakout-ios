//
//  CommentButton.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/22/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit
import Sweeft

class CommentButton: UIButton {
    
    var previousText: String = .empty
    var activityIndicator = UIActivityIndicatorView()
    
    var isLoading: Bool = false {
        didSet {
            if oldValue != isLoading {
                if isLoading {
                    startSpining()
                } else {
                    stopSpinning()
                }
            }
        }
    }
    
    private func startSpining() {
        isEnabled = false
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.color = .mainOrange
        previousText = (titleLabel?.text).?
        setTitle("", for: .normal)
        let side = frame.height - 2
        let x = (frame.width - side - 2)/2
        activityIndicator.frame = CGRect(x: x, y: 1, width: side, height: side)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        layoutIfNeeded()
    }
    
    private func stopSpinning() {
        isEnabled = true
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        setTitle(previousText, for: .normal)
    }
    
}
