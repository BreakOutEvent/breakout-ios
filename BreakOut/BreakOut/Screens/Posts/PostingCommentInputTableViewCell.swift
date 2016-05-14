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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.postButton.enabled = false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == ""  {
            self.postButton.enabled = false
        }else{
            self.postButton.enabled = true
        }
        
        return true
    }
    
// MARK: - Button Actions

    @IBAction func postButtonPressed(sender: UIButton) {
    }
}
