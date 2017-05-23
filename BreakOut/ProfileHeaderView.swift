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
    
    weak var containingViewController: UIViewController?
    
    var imagePicker = UIImagePickerController()
    
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
    
    @IBAction func didPress(_ sender: Any) {
        imagePicker.delegate = self
        let optionMenu = UIAlertController(title: nil, message: "profileImageSource".local, preferredStyle: .actionSheet)
        
        let photoLibraryOption = UIAlertAction(title: "photoLibrary".local, style: .default) { alert in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.modalPresentationStyle = .popover
            self.containingViewController?.present(self.imagePicker, animated: true, completion: nil)
        }
        let cameraOption = UIAlertAction(title: "takeAPhoto".local, style: .default) { alert in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraDevice = .front
            self.imagePicker.modalPresentationStyle = .popover
            self.containingViewController?.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let logoutOption = UIAlertAction(title: "logout".local, style: .destructive) { alert in
            optionMenu.dismiss(animated: true, completion: nil)
            BreakOut.shared.logout()
            CurrentUser.resetUser()
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_PRESENT_WELCOME_SCREEN), object: nil)
        }
        
        let cancelOption = UIAlertAction(title: "cancel".local, style: .cancel) { alert in
            optionMenu.dismiss(animated: true, completion: nil)
        }
        
        //Adding the actions to the action sheet. Here, camera will only show up as an option if the camera is available in the first place.
        optionMenu.addAction(photoLibraryOption)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            optionMenu.addAction(cameraOption)
        }
        optionMenu.addAction(logoutOption)
        optionMenu.addAction(cancelOption)
        
        //Now that the action sheet is set up, we present it.
        containingViewController?.present(optionMenu, animated: true, completion: nil)
    }

}

extension ProfileHeaderView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.profileImageView.image = image
        CurrentUser.shared.picture = image
        CurrentUser.shared.uploadUserData()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}


