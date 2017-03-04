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
    var posting: Post! {
        didSet {
            populate()
        }
    }
    
    var playImageView = UIImageView()
    
    var video: Video? {
        didSet {
            guard video != oldValue else {
                return
            }
            videoController.player?.pause()
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
    
    func populate() {
        messageLabel?.text = posting.text
        
        let latitude = (posting.location?.latitude).?
        let longitude = (posting.location?.longitude).?
        timestampLabel?.text = posting.date.toString()
        
        if (posting.location?.locality != nil && posting.location?.locality != "") {
            locationLabel?.text = posting.location?.locality
        } else if (Int(latitude) != 0 && Int(longitude) != 0) {
            locationLabel?.text = String(format: "lat: %3.3f long: %3.3f", latitude, longitude)
        } else {
            locationLabel?.text = "unknownLocation".localized(with: "unknown location")
        }
        
        images = posting.media
            .flatMap { $0.image }
            .filter { $0.hasContent() }
        
        video = posting.media.flatMap({ $0.video }).first
        
        // Set the team image & name
        if posting.participant.team?.name != nil {
            teamNameLabel.text = posting.participant.team?.name
        }
        teamPictureImageView.image = posting.participant.image?.image ?? UIImage(named: "emptyProfilePic")
        
        
        // Check if Posting has an attached challenge
        if posting.challenge != nil {
            challengeLabel.text = posting.challenge?.text
            challengeLabelHeightConstraint.constant = 34.0
            challengeView.isHidden = false
        } else {
            challengeLabel.text = ""
            challengeLabelHeightConstraint.constant = 0.0
            challengeViewHeightConstraint.constant = 0.0
            challengeView.isHidden = true
        }
        
        if (video?.playbackSessionOpen).? {
            addVideoView()
        }
        
        loadInterface()
    }
    
    func loadInterface() {
        likesButton.setTitle(String(format: "%i %@", posting.likes, "likes".local), for: .normal)
        
        if posting.liked {
            likesButton.setTitleColor(.brick, for: .normal)
            likesButton.imageView?.set(image: #imageLiteral(resourceName: "post-like-selected_Icon"), with: .brick)
        } else {
            likesButton.setTitleColor(.lightGray, for: .normal)
            likesButton.imageView?.set(image: #imageLiteral(resourceName: "post-like_Icon"), with: .lightGray)
        }
        
        likesButton.isEnabled = CurrentUser.shared.isLoggedIn()
        
        commentsButton.imageView?.set(image: #imageLiteral(resourceName: "post-comment_Icon"), with: .lightGray)
        
        // Add count for comments
        commentsButton.setTitle(String(format: "%i %@", posting.comments.count, "comments".localized(with: "Comments")), for: .normal)
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
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
        
        videoController.view.layer.cornerRadius = 4.0
        videoController.view.clipsToBounds = true
        
        likesButton.setTitleColor(.lightGray, for: .normal)
        commentsButton.setTitleColor(.lightGray, for: .normal)
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
    
    func addVideoView() {
        videoController.videoGravity = AVLayerVideoGravityResizeAspect
        videoController.view.frame = postingPictureImageView.frame
        videoController.view.isUserInteractionEnabled = true
        videoController.player = video?.videoPlayer
        contentView.addSubview(videoController.view)
        postingPictureImageView.image = nil
    }
    
    @IBAction func postingImageButtonPressed(_ sender: UIButton) {
        if let video = video {
            guard videoController.player == nil else {
                return
            }
            addVideoView()
            video.play()
        } else if let fullscreenImageViewController = DTPhotoViewerController(referencedView: postingPictureImageView, image: postingPictureImageView.image) {
            fullscreenImageViewController.dataSource = self
            self.parentTableViewController?.present(fullscreenImageViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func likesButtonPressed(_ sender: UIButton) {
        posting.toggleLike().onSuccess(call: **self.loadInterface).onError(call: **self.loadInterface)
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
