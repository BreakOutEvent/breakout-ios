//
//  PostingCommentInputTableViewCell.swift
//  BreakOut
//
//  Created by Leo Käßner on 14.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

class PostingCommentInputTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentInputTextField: UITextField!
    
    //var post: BOPost?
    var post: Posting?
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
//        let comment = BOComment.create(0, text: commentInputTextField.text ?? "", postID: post?.uuid ?? 0)
//        comment.upload()
//        let dict: NSDictionary =  ["text": commentInputTextField.text!, "postID": (post?.uuid)!, "id": 0, "date": Date().timeIntervalSince1970, "user":["firstname": CurrentUser.shared.firstname! as String, "lastname": CurrentUser.shared.lastname!], "profilePic":""]
//        let newComment = Comment(dict: dict)
//        post?.comments?.append(newComment)
//        //post?.comments.insert(comment)
//        //post?.save()
//        commentInputTextField.text = ""
//        if let handler = reloadHandler {
//            handler()
//        }
    }
}
