//
//  Extensions.swift
//  BreakOut
//
//  Created by Leo Käßner on 20.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Sweeft

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

extension UIImageView {
    
    public override func set(color: UIColor) {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
    
}

extension UIImagePickerController {
    
    func present(over controller: UIViewController,
                 with source: UIImagePickerControllerSourceType,
                 mediaTypes: [String]? = nil) {
        
        .main >>> {
            self.allowsEditing = true
            self.sourceType = source
            if source == .camera {
                self.cameraDevice = .front
            }
            self.modalPresentationStyle = .popover
            self.mediaTypes = mediaTypes ?? UIImagePickerController.availableMediaTypes(for: source) ?? .empty
            controller.present(self, animated: true, completion: nil)
        }
    }
    
}

extension UIView {

    public func set(color: UIColor) {
        subviews
            .flatMap { $0 as? UILabel }
            .forEach { $0.textColor = color }
        subviews
            .flatMap { $0 as? UIImageView }
            .forEach { $0.set(color: color) }
    }
    
}

extension UITableViewCell {
    
    public override func set(color: UIColor) {
        contentView.set(color: color)
    }
    
}


extension NSAttributedString {
    
    static func localized(_ string: String, comment: String = .empty, with color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: string.localized(with: comment), attributes: [NSForegroundColorAttributeName : color])
    }
    
}

extension String {
    
    var local: String {
        return localized(with: .empty)
    }
    
    func localized(with comment: String) -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
}

extension UILabel {
    
    @IBInspectable var localizedText: String {
        get { return "" }
        set {
            self.text = newValue.local
        }
    }
}

extension UITextView {
    
    @IBInspectable var localizedText: String {
        get { return "" }
        set {
            self.text = newValue.local
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
        return string(using: "hh:mm a, EEE dd MMM")
    }
    
}
