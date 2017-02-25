//
//  PostingCommentInputTableViewCell.swift
//  BreakOut
//
//  Created by Leo Käßner on 14.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Sweeft

class PostingCommentInputTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentInputTextField: UITextField!
    
    var post: Post!
    
    var reloadHandler: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.postButton.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == ""  {
            self.postButton.isEnabled = false
        } else {
            self.postButton.isEnabled = true
        }
        
        return true
    }
    
// MARK: - Button Actions

    @IBAction func postButtonPressed(_ sender: UIButton) {
        post.comment(commentInputTextField.text.?) { posted in
            self.commentInputTextField.text = .empty
        }
    }
}
