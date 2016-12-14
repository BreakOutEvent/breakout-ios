//
//  Extensions.swift
//  BreakOut
//
//  Created by Leo Käßner on 20.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import SwiftyJSON

public extension UIImage {
    public func hasContent() -> Bool {
        let cgref = self.cgImage
        let cim = self.ciImage
        if cgref == nil && cim == nil {
            return false
        } else {
            return true
        }
    }
}

extension UILabel {
    
    @IBInspectable var localizedText: String {
        get { return "" }
        set {
            self.text = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UITextView {
    
    @IBInspectable var localizedText: String {
        get { return "" }
        set {
            self.text = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UIImageView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UIButton {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension Array {
    
    func first(_ bound: Int) -> [Element] {
        guard let upper = [count, bound].min() else {
            return []
        }
        return (0..<upper).map { self[$0] }
    }
    
}

extension Date {
    
    func toString() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "hh:mm a, EEE dd MMM"
        return dateformatter.string(from: self)
    }
    
}

extension JSON {
    
    var date: Date? {
        guard let timestap = self.int else {
            return nil
        }
        return Date(timeIntervalSince1970: Double(timestap))
    }
    
}
