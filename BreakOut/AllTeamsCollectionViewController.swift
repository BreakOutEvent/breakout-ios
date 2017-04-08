//
//  AllTeamsCollectionViewController.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/15/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import UIKit

private let reuseIdentifier = "Cell"

class AllTeamsCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    var teams = [Team]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create menu buttons for navigation item
        let barButtonImage = UIImage(named: "menu_Icon_white")
        if barButtonImage != nil {
            self.addLeftBarButtonWithImage(barButtonImage!)
        }
        
        // Style the navigation bar
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = .mainOrange
        self.navigationController!.navigationBar.backgroundColor = .mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.view.backgroundColor = .ultraLightBackgroundColor
        collectionView?.backgroundColor = .ultraLightBackgroundColor
        
        title = "allTeamsTitle".local
        // Only fetch the latest instead of everything...
        loadingActivityIndicator.startAnimating()
        Team.current().onSuccess { teams in
            let images = teams ==> { $0.image }
            images >>> **{
                self.collectionView?.reloadData()
            }
            self.loadingActivityIndicator.stopAnimating()
            self.loadingActivityIndicator.isHidden = true
            self.teams = teams
            self.collectionView?.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        UIView.animate(withDuration: 0.1, animations: {
            self.navigationController?.navigationBar.alpha = 1
            self.view.layoutIfNeeded()
        }) { _ in
            self.view.layoutIfNeeded() // Panic!
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teams.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? TeamCollectionViewCell {
            cell.team = teams[indexPath.row]
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.1) {
            self.navigationController?.navigationBar.alpha = 0.0
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let teamController = storyboard.instantiateViewController(withIdentifier: "TeamViewController")
        
        if let teamController = teamController as? TeamViewController {
            teamController.team = teams[indexPath.row]
        }
        
        navigationController?.pushViewController(teamController, animated: true)
    
    }

}

extension AllTeamsCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Super Hacky. Don't look
        
        let screenSize = UIScreen.main.bounds.size
        let width = (screenSize.width - 9) / 2
        let height = width + 50
        return CGSize(width: width, height: height)
    }
    
}
