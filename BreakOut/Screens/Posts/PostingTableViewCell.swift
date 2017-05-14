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

    @IBOutlet weak var postingMediaView: UIView!
    @IBOutlet weak var postingPictureImageView: UIImageView!
    @IBOutlet weak var teamPictureImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var challengeView: UIView!
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var playOverlay: UIView!
    @IBOutlet weak var shareButton: UIButton!
    
    var videoController: AVPlayerViewController = AVPlayerViewController()
    var posting: Post! {
        didSet {
            populate()
        }
    }
    
    var video: Video? {
        didSet {
            guard video != oldValue else {
                return
            }
            videoController.player?.pause()
            videoController.view.removeFromSuperview()
        }
    }
    
    var images: [Image] = .empty {
        didSet {
            if let image = images.first {
                postingPictureImageView.image = image.image ?? #imageLiteral(resourceName: "image_placeholder")
                postingMediaView.isHidden = false
            } else {
                postingMediaView.isHidden = true
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
        
        video = posting.media.flatMap({ $0.video }).first
        
        teamNameLabel.text = posting.prettyTeamName
        teamPictureImageView.image = posting.participant.image?.image ?? UIImage(named: "emptyProfilePic")
        
        
        // Check if Posting has an attached challenge
        if posting.challenge != nil {
            challengeLabel.text = posting.challenge?.text
            challengeView.isHidden = false
        } else {
            challengeView.isHidden = true
        }
        
        playOverlay.isHidden = video == nil
        
        if (video?.playbackSessionOpen).? {
            addVideoView()
        }
        
        loadInterface()
    }
    
    func loadInterface() {
        likesButton.setTitle("likes".localized(amount: posting.likes), for: .normal)
        
        if posting.liked {
            likesButton.setTitleColor(.brick, for: .normal)
            likesButton.imageView?.set(image: #imageLiteral(resourceName: "post-like-selected_Icon"), with: .brick)
        } else {
            likesButton.setTitleColor(.lightGray, for: .normal)
            likesButton.imageView?.set(image: #imageLiteral(resourceName: "post-like_Icon"), with: .lightGray)
        }
        commentsButton.setTitleColor(.lightGray, for: .normal)
        commentsButton.imageView?.set(image: #imageLiteral(resourceName: "post-comment_Icon"), with: .lightGray)
        
        shareButton.setTitleColor(.lightGray, for: .normal)
        shareButton.imageView?.set(image: #imageLiteral(resourceName: "share_icon"), with: .lightGray)
        
        challengeView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        
        likesButton.isEnabled = CurrentUser.shared.isLoggedIn()
        
        // Add count for comments
        commentsButton.setTitle("comments".localized(amount: posting.comments.count), for: .normal)
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
        
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.clipsToBounds = true
        effectView.frame = playOverlay.bounds
        playOverlay.layer.cornerRadius = 22
        playOverlay.clipsToBounds = true        
        playOverlay.insertSubview(effectView, at: 0)
        
        commentsButton.isEnabled = false
        
        // Styling of the Posting Picture
        commentsButton.imageView?.alpha = 0.201
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
    }
    
    func addVideoView() {
        videoController.videoGravity = AVLayerVideoGravityResizeAspect
        videoController.view.frame = postingMediaView.bounds
        videoController.view.isUserInteractionEnabled = true
        videoController.player = video?.videoPlayer
        postingMediaView.addSubview(videoController.view)
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
    
    @IBAction func teamPressed(_ sender: Any) {
        
        UIView.animate(withDuration: 0.1) {
            self.parentTableViewController?.navigationController?.navigationBar.alpha = 0.0
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let teamController = storyboard.instantiateViewController(withIdentifier: "TeamViewController")
        
        if let teamController = teamController as? TeamViewController {
            teamController.partialTeam = posting.participant.team
        }
        
        parentTableViewController?.navigationController?.pushViewController(teamController, animated: true)
        
    }
    
    @IBAction func likesButtonPressed(_ sender: UIButton) {
        posting.toggleLike().onSuccess(call: **self.loadInterface).onError(call: **self.loadInterface)
    }

    @IBAction func commentsButtonPressed(_ sender: UIButton) {
        loadInterface()
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        loadInterface()
        let activity = UIActivityViewController(activityItems: [posting.sharingURL], applicationActivities: nil)
        parentTableViewController?.present(activity, animated: true, completion: nil)
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
        imageView.image = images[index].image
    }
    
}
