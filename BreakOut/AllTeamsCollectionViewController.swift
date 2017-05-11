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

class AllTeamsCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var filterViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    var selectedEvents = [Int]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var teamsByEvent = [Int : [Team]]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var teams: [Team] {
        return selectedEvents.flatMap { teamsByEvent[$0] ?? [] }
    }

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

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teams.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? TeamCollectionViewCell {
            cell.team = teams[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? EventSelectorViewController {
            controller.delegate = self
        }
    }
    
    @IBAction func didPressFilter(_ sender: Any) {
        let newHeight: CGFloat = filterViewConstraint.constant == 0 ? -260 : 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.filterViewConstraint.constant = newHeight
            self.view.layoutIfNeeded()
        }
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

extension AllTeamsCollectionViewController: EventSelectorDelegate {
    
    func eventSelector(_ eventSelector: EventSelectorViewController, didChange selected: [Int]) {
        selectedEvents = selected
        let needed = selected - teamsByEvent.keys.array
        
        Team.byEvents(needed.array).onSuccess { teams in
            self.loadingActivityIndicator.stopAnimating()
            let images = teams.flatMap({ $0 }) ==> { $0.image }
            images >>> **self.collectionView.reloadData
            let new = zip(needed, teams).map { $0 }
            let items = new >>= id
            self.teamsByEvent = self.teamsByEvent + items
        }
        .onError { _ in
            self.loadingActivityIndicator.stopAnimating()
        }
    }
    
}
