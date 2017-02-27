//
//  PostingTableViewCell.swift
//  BreakOut
//
//  Created by Leo Käßner on 24.04.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Sweeft
import DTPhotoViewerController

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
    
    var videoController: AVPlayerViewController = AVPlayerViewController()
    var playImageView = UIImageView()
    
    var video: URL? {
        didSet {
            guard video != oldValue else {
                return
            }
            videoController.player?.pause()
            videoController.player = nil
            videoController.view.removeFromSuperview()
        }
    }
    
    var images: [UIImage] = .empty {
        didSet {
            if let image = images.first {
                postingPictureImageView.image = image
                postingPictureImageViewHeightConstraint.constant = 200.0
            } else {
                postingPictureImageViewHeightConstraint.constant = 0.0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Styling of the Challenge-Box
        self.challengeView.layer.borderWidth = 1
        self.challengeView.layer.borderColor = UIColor.lightGray.cgColor
        self.challengeView.layer.cornerRadius = 4.0
        self.challengeView.backgroundColor = UIColor.white
        
        // Styling of the Posting Picture
        self.postingPictureImageView.layer.cornerRadius = 4.0
        self.videoController.view.layer.cornerRadius = 4.0
        self.videoController.view.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Styling of the Team Picture
        self.teamPictureImageView.layer.cornerRadius = self.teamPictureImageView.frame.size.width/2.0
        
        playImageView.removeFromSuperview()
        if video != nil {
            playImageView.image = #imageLiteral(resourceName: "play_Icon")
            playImageView.frame = CGRect(x: postingPictureImageView.bounds.width/2 - 24,
                                         y: postingPictureImageView.bounds.height/2 - 24,
                                         width: 48,
                                         height: 48)
            postingPictureImageView.addSubview(playImageView)
        }
        
    }
    
    @IBAction func postingImageButtonPressed(_ sender: UIButton) {
        if let video = video {
            guard videoController.player == nil else {
                return
            }
            videoController.videoGravity = AVLayerVideoGravityResizeAspect
            videoController.view.frame = postingPictureImageView.frame
            videoController.player = AVPlayer(url: video)
            videoController.view.isUserInteractionEnabled = true
            contentView.addSubview(videoController.view)
            videoController.player?.play()
            postingPictureImageView.image = nil
        } else if let fullscreenImageViewController = DTPhotoViewerController(referencedView: postingPictureImageView, image: postingPictureImageView.image) {
            fullscreenImageViewController.dataSource = self
            self.parentTableViewController?.present(fullscreenImageViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func likesButtonPressed(_ sender: UIButton) {
    }

    @IBAction func commentsButtonPressed(_ sender: UIButton) {
    }
}

extension PostingTableViewCell: DTPhotoViewerControllerDataSource {
    
    func numberOfItems(in photoViewerController: DTPhotoViewerController) -> Int {
        return images.count
    }
    
    func photoViewerController(_ photoViewerController: DTPhotoViewerController, referencedViewForPhotoAt index: Int) -> UIView? {
        return postingPictureImageView
    }
    
    func photoViewerController(_ photoViewerController: DTPhotoViewerController, configurePhotoAt index: Int, withImageView imageView: UIImageView) {
        imageView.image = images[index]
    }
    
}
