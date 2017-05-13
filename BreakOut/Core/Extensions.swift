//
//  Extensions.swift
//  BreakOut
//
//  Created by Leo Käßner on 20.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Sweeft

import OneSignal

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
    
    public func set(image: UIImage?, with color: UIColor) {
        self.image = image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
    
    public override func set(color: UIColor) {
        set(image: self.image, with: color)
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
            self.videoQuality = .typeHigh
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
    
    var singularLocal: String {
        return "\(self)Singular".local
    }

    var pluralLocal: String {
        return "\(self)Plural".local
    }
    
    func localized(amount: Int) -> String {
        if amount == 1 {
            return "\(amount) \(singularLocal)"
        } else {
            return "\(amount) \(pluralLocal)"
        }
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
    
    func skipping(oneInEvery n: Int) -> [Element] {
        return self |> { $1 % n != 0 }
    }
    
    func including(oneInEvery n: Int) -> [Element] {
        return self |> { $1 % n == 0 }
    }
    
}

extension Calendar.Component {
    
    var local: String {
        switch self {
        case .day: return "days".local
        case .hour: return "hours".local
        case .minute: return "min"
        default: return .empty
        }
    }
    
    func localized(amount: Int) -> String {
        let format = "time".local
        let timeString = "\(amount) \(self.local)"
        return String(format: format, timeString)
    }
    
}

extension Date {
    
    func toString() -> String {
        let diff = Date.now - self
        let diffs: [(Int, Calendar.Component)] = [(diff.days, .day),
                                                  (diff.hours, .hour),
                                                  (diff.minutes, .minute)]
        
        let reduced = diffs ==> nil ** { (result, diff: (Int, Calendar.Component)) in
            return result ?? (diff.0 > 0 ? diff : nil)
        }
        
        guard let relevant = reduced else {
            return "just_now".local // Just now...
        }
        
        switch relevant.1 {
        case .day:
            if relevant.0 > 3 {
                return string(using: "dd MMM, YYYY")
            }
            fallthrough
        default:
            return relevant.1.localized(amount: relevant.0)
        }
        
        
    }
    
}

extension OneSignal {
    
    static var token: String? {
        guard let state = getPermissionSubscriptionState(),
            let token = state.subscriptionStatus.userId else {
                
            return nil
        }
        return token
    }
    
}
