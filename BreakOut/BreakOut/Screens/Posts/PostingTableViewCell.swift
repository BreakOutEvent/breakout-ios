//
//  PostingTableViewCell.swift
//  BreakOut
//
//  Created by Leo Käßner on 24.04.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

import GGFullscreenImageViewController

class PostingTableViewCell: UITableViewCell {
    
    weak var parentTableViewController: UITableViewController?

    @IBOutlet weak var postingPictureImageView: UIImageView!
    @IBOutlet weak var postingPictureImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var teamPictureImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var challengeView: UIView!
    @IBOutlet weak var challengeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var challengeLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Styling of the Challenge-Box
        self.challengeView.layer.borderWidth = 1
        self.challengeView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.challengeView.layer.cornerRadius = 4.0
        self.challengeView.backgroundColor = UIColor.whiteColor()
        
        // Styling of the Posting Picture
        self.postingPictureImageView.layer.cornerRadius = 4.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Styling of the Team Picture
        self.teamPictureImageView.layer.cornerRadius = self.teamPictureImageView.frame.size.width/2.0
    }
    
    @IBAction func postingImageButtonPressed(sender: UIButton) {
        let fullscreenImageViewController:GGFullscreenImageViewController = GGFullscreenImageViewController()
        fullscreenImageViewController.liftedImageView = postingPictureImageView
        //fullscreenImageViewController.liftedImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.parentTableViewController?.presentViewController(fullscreenImageViewController, animated: true, completion: nil)
    }
    
    @IBAction func likesButtonPressed(sender: UIButton) {
    }

    @IBAction func commentsButtonPressed(sender: UIButton) {
    }
}
