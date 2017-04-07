//
//  ChatViewController.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/27/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import NMessenger
import AsyncDisplayKit
import Sweeft

class ChatViewController: NMessengerViewController {
    
    var isMasked: Bool = true
    
    var chat: GroupMessage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = chat.title
//        if let view = self.inputBarView as? NMessengerBarView {
//            view.inputTextViewPlaceholder = "Message"
//        }
        self.messengerView.addMessages(cells(), scrollsToMessage: false)
        self.messengerView.scrollToLastMessage(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func getInputBar() -> InputBarView {
        return ChatInputBarView.create(controller: self)
    }
    
    func startSpinning() {
        guard let inputBarView = inputBarView as? ChatInputBarView else {
            return
        }
        inputBarView.disable()
    }
    
    func stopSpinning() {
        guard let inputBarView = inputBarView as? ChatInputBarView else {
            return
        }
        inputBarView.enable()
    }
    
    func cells() -> [GeneralMessengerCell] {
        let users = chat.users.dictionaryWithoutOptionals { ($0.id, $0) }
        return chat.messageGroups => self.cell <** users
    }
    
    func cell(for group: (Int, [Message]), users: [Int : Participant]) -> GeneralMessengerCell {
        
        var users = users
        
        let cell = MessageGroup()
        cell.currentViewController = self
        cell.cellPadding = self.messagePadding
        
        group.1 => { message in
            let content = TextContentNode(textMessageString: message.text,
                                          currentViewController: self,
                                          bubbleConfiguration: self)
            
            let message = MessageNode(content: content)
            message.cellPadding = self.messagePadding
            message.currentViewController = self
            cell.addMessageToGroup(message, completion: nil)
        }
        
        cell.isIncomingMessage = group.0 != CurrentUser.shared.id
        
        if cell.isIncomingMessage {
            let avatar = ASImageNode()
            avatar.layer.cornerRadius = 10
            avatar.clipsToBounds = true
            avatar.preferredFrameSize = CGSize(width: 20, height: 20)
            avatar.image = users[group.0]?.image?.image
            users[group.0]?.onChange { user in
                avatar.image = user.image?.image
            }
            cell.avatarNode = avatar
        }
        
        return cell
        
    }
    
    override func sendText(_ text: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
        startSpinning()
        let content = TextContentNode(textMessageString: text,
                                      currentViewController: self,
                                      bubbleConfiguration: self)
        
        let message = MessageNode(content: content)
        message.cellPadding = self.messagePadding
        message.currentViewController = self
        message.isIncomingMessage = false
        chat.send(message: text).onSuccess { _ in
            self.addMessageToMessenger(message)
            self.stopSpinning()
        }
        .onError { _ in
            self.inputBarView.textInputView.text = text
            self.stopSpinning()
        }
        return message
    }
    
}

extension ChatViewController: BubbleConfigurationProtocol {
    
    func getIncomingColor() -> UIColor {
        return .bubbleGray
    }
    
    func getOutgoingColor() -> UIColor {
        return .mainOrange
    }
    
    func getBubble() -> Bubble {
        let bubble = DefaultBubble()
        bubble.hasLayerMask = true
        return bubble
    }
    
    func getSecondaryBubble() -> Bubble {
        return StandardBubbleConfiguration().getSecondaryBubble()
    }
    
}
