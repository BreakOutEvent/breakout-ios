//
//  ProfileHeaderView.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/23/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit
import Sweeft

class ProfileHeaderView: HeaderView {

    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    static var shared: ProfileHeaderView! = {
        guard let nibs = Bundle.main.loadNibNamed("ProfileHeaderView", owner: self, options: nil) else {
            return nil
        }
        let headers = nibs.flatMap { $0 as? ProfileHeaderView }
        guard let header = headers.first else {
            return nil
        }
        return header
    }()
    
    func populate() {
        guard let first = CurrentUser.shared.firstname, let last = CurrentUser.shared.lastname else {
            nameLabel.text = .empty
            return
        }
        nameLabel.text = "\(first) \(last)"
        profileImageView.image = CurrentUser.shared.picture ?? #imageLiteral(resourceName: "emptyProfilePic")
        CurrentUser.shared.profilePic?.onChange(do: **self.populate)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        populate()
        profileImageView.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
    }
    

}
