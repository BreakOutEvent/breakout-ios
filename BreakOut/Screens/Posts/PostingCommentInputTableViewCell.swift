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

    @IBOutlet weak var postButton: CommentButton!
    @IBOutlet weak var commentInputTextField: UITextField!
    
    var post: Post!
    
    var reloadHandler: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.commentInputTextField.placeholder = "new_comment".local
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
        postButton.isLoading = true
        post.comment(commentInputTextField.text.?).onSuccess { comment in
            self.commentInputTextField.text = .empty
            self.postButton.isEnabled = false
            self.postButton.isLoading = false
        }
        .onError { _ in
            self.postButton.isLoading = false
        }
    }
}
