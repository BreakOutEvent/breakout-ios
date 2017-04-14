//
//  ChatInputBarView.swift
//  BreakOut
//
//  Created by Mathias Quintero on 4/7/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit
import NMessenger

class ChatInputBarView: InputBarView, UITextViewDelegate {

    @IBOutlet open weak var inputBarView: UIView!
    @IBOutlet open weak var sendButton: CommentButton!
    @IBOutlet open weak var textInputAreaViewHeight: NSLayoutConstraint!
    @IBOutlet open weak var textInputViewHeight: NSLayoutConstraint!
    
    open var numberOfRows:CGFloat = 3
    open var inputTextViewPlaceholder: String = "message".local
        {
        willSet(newVal)
        {
            self.textInputView.text = newVal
        }
    }
    
    fileprivate let textInputViewHeightConst: CGFloat = 30
    
    static func create(controller: NMessengerViewController) -> ChatInputBarView! {
        guard let nibs = Bundle.main.loadNibNamed("ChatInputBarView", owner: self, options: nil) else {
            return nil
        }
        let views = nibs.flatMap { $0 as? ChatInputBarView }
        guard let view = views.first else {
            return nil
        }
        view.controller = controller
        view.textInputView.clipsToBounds = true
        view.textInputView.layer.cornerRadius = 5
        view.textInputView.layer.borderWidth = 0.5
        view.textInputView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        view.textInputView.delegate = view
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        view.sendButton.setTitle("sendMessage".local, for: .normal)
        return view
    }
    
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == inputTextViewPlaceholder {
            textView.text = ""
            DispatchQueue.main.async(execute: {
                textView.selectedRange = NSMakeRange(0, 0)
            });
        }
        textView.textColor = .messageTextColor
        UIView.animate(withDuration: 0.1, animations: {
            self.sendButton.isEnabled = true
        })
        return true
    }
    
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if self.textInputView.text.isEmpty {
            self.addInputSelectorPlaceholder()
        } else if sendButton.isLoading {
            return false
        }
        UIView.animate(withDuration: 0.1, animations: {
            self.sendButton.isEnabled = false
        })
        self.textInputView.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == "" && (text != "\n")
        {
            UIView.animate(withDuration: 0.1, animations: {
                self.sendButton.isEnabled = true
            })
            return true
        }
        else if (text == "\n") && textView.text != ""{
            if textView == self.textInputView {
                textInputViewHeight.constant = textInputViewHeightConst
                textInputAreaViewHeight.constant = textInputViewHeightConst + 10
                _ = self.controller.sendText(self.textInputView.text,isIncomingMessage: false)
                self.textInputView.text = ""
                return false
            }
        }
        else if (text != "\n")
        {
            
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            
            var textWidth: CGFloat = UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset).width
            
            textWidth -= 2.0 * textView.textContainer.lineFragmentPadding
            
            let boundingRect: CGRect = newText.boundingRect(with: CGSize(width: textWidth, height: 0), options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], attributes: [NSFontAttributeName: textView.font!], context: nil)
            
            let numberOfLines = boundingRect.height / textView.font!.lineHeight;
            
            
            return numberOfLines <= numberOfRows
        }
        return false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        textInputViewHeight.constant = newFrame.size.height
        
        textInputAreaViewHeight.constant = newFrame.size.height + 10
    }
    
    fileprivate func addInputSelectorPlaceholder() {
        self.textInputView.text = self.inputTextViewPlaceholder
        self.textInputView.textColor = UIColor.lightGray
    }
    
    func disable() {
        sendButton.isLoading = true
    }
    
    func enable() {
        sendButton.isLoading = false
    }
    
    @IBAction func sendButtonClicked(_ sender: AnyObject) {
        textInputViewHeight.constant = textInputViewHeightConst
        textInputAreaViewHeight.constant = textInputViewHeightConst + 10
        if self.textInputView.text != "", self.textInputView.text != nil {
            _ = self.controller.sendText(self.textInputView.text, isIncomingMessage: false)
            self.textInputView.text = ""
            sendButton.isLoading = true
        }
    }

}
