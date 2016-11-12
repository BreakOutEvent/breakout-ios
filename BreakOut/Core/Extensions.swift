//
//  Extensions.swift
//  BreakOut
//
//  Created by Leo Käßner on 20.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation

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

extension Sequence {
    func groupBy<Key: Hashable>(handler: (Iterator.Element) -> Key) -> [Key: [Iterator.Element]] {
        var grouped = [Key: Array<Iterator.Element>]()
        
        self.forEach { item in
            let key = handler(item)
            if grouped[key] == nil {
                grouped[key] = [item]
            } else {
                grouped[key]?.append(item)
            }
        }
        
        return grouped
    }
}
