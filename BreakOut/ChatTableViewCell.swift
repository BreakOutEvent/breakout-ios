//
//  ChatTableViewCell.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/27/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit
import MDGroupAvatarView
import Sweeft

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarViews: MDGroupAvatarView!
    @IBOutlet weak var namesLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var message: GroupMessage? {
        didSet {
            namesLabel.text = message?.title
            lastMessageLabel.text = message?.lastMessage ?? "No Message"
            timeLabel.text = message?.lastActivity?.toString() ?? ""
            setImages()
        }
    }
    
    func setImages() {
        let others = message?.users |> { $0.id != CurrentUser.shared.id }
        others >>> **{
            self.setImages(members: others)
        }
        setImages(members: others)
    }
    
    func setImages(members: [Participant]) {
        let images = members => { $0.image?.image ?? #imageLiteral(resourceName: "emptyProfilePic") }
        avatarViews.setAvatarImages(images.array(withFirst: 3), realTotal: members.count + 1)
    }
    
}
