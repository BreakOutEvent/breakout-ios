//
//  ChatViewController.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/27/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import NMessenger
import KSTokenView
import AsyncDisplayKit
import Sweeft

class ChatViewController: NMessengerViewController {
    
    var isMasked: Bool = true
    
    var chat: GroupMessage!
    
    var addedParticipants = [Participant]()
    
    lazy var recepientsField: KSTokenView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30)
        return KSTokenView(frame: frame)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = chat?.title ?? "newMessage".local
        self.messengerView.addMessages(cells(), scrollsToMessage: false)
        self.messengerView.scrollToLastMessage(animated: false)
        if chat == nil {
            view.addSubview(recepientsField)
            recepientsField.promptText = "recepient".local
            recepientsField.style = .rounded
            recepientsField.placeholder = "search".local
            recepientsField.searchResultBackgroundColor = .white
            recepientsField.activityIndicatorColor = .mainOrange
            recepientsField.searchResultSize = CGSize(width: self.view.frame.width, height: view.frame.height - 60)
            recepientsField.direction = .horizontal
            recepientsField.layer.borderWidth = 0
//            recepientsField._tokenField.layer.borderWidth = 0
//            recepientsField._tokenField.borderStyle = .none
            _ = recepientsField.becomeFirstResponder()
        }
        recepientsField.delegate = self
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
        if chat == nil {
            return []
        }
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
    
    func send(text: String, message: MessageNode) {
        chat.send(message: text).onSuccess { _ in
            self.addMessageToMessenger(message)
            self.stopSpinning()
        }
        .onError { _ in
            self.inputBarView.textInputView.text = text
            self.stopSpinning()
        }
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
        if chat == nil {
            GroupMessage.create(with: addedParticipants).onSuccess { chat in
                self.chat = chat
                self.title = chat.title
                self.send(text: text, message: message)
                self.recepientsField.removeFromSuperview()
            }
            .onError { _ in
                self.inputBarView.textInputView.text = text
                self.stopSpinning()
            }
        } else {
            send(text: text, message: message)
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

extension ChatViewController: KSTokenViewDelegate {
    
    func tokenView(_ token: KSTokenView, performSearchWithString string: String, completion: ((Array<AnyObject>) -> Void)?) {
        Participant.search(for: string).onSuccess { participants in
            completion?(participants)
        }
        .onError { _ in
            completion?([])
        }
    }
    
    func tokenView(_ token: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        guard let participant = object as? Participant else {
            return ""
        }
        return participant.name
    }
    
    func tokenView(_ tokenView: KSTokenView, didAddToken token: KSToken) {
        guard let participant = token.object as? Participant else {
            return
        }
        addedParticipants.append(participant)
    }
    
    func tokenView(_ tokenView: KSTokenView, didDeleteToken token: KSToken) {
        guard let participant = token.object as? Participant else {
            return
        }
        addedParticipants <| { $0 !== participant }
    }
    
}
