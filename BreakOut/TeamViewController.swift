//
//  TeamViewController.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/13/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit
import Sweeft
import Pageboy

final class TeamViewController: PageboyViewController, Observable {
    
    lazy var barHeight: CGFloat = {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }()
    
    var imageHeight: CGFloat {
        return postingsViewController.tableView.parallaxHeader.height - barHeight
    }
    
    var wasLoadedBefore = false
    
    @IBOutlet weak var subMenu: UIView!
    @IBOutlet weak var buttonsToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var postingsButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var challengesButton: UIButton!
    @IBOutlet weak var sponsorsButton: UIButton!
    
    var subMenuSelectionBarView: UIView = UIView()
    var previousConstant: CGFloat = 180
    
    var listeners = [Listener]()
    
    var partialTeam: Team?
    var team: Team?
    
    private func create<V: UIViewController>() -> V {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let name = String(describing: V.self)
        let controller = storyboard.instantiateViewController(withIdentifier: name)
        return controller as! V
    }
    
    lazy var postingsViewController: TeamProfilePostingsTableViewController = {
        let controller: TeamProfilePostingsTableViewController = self.create()
        controller.teamProfileController = self
        return controller
    }()
    
    lazy var mapViewController: MapViewController = {
        let controller: MapViewController = self.create()
        controller.teamController = self
        return controller
    }()
    
    lazy var infoViewController: TeamInfoTableViewController = {
        let controller: TeamInfoTableViewController = self.create()
        controller.teamProfileController = self
        return controller
    }()
    
    lazy var challengesViewController: TeamChallengesOverviewTableViewController = {
        let controller: TeamChallengesOverviewTableViewController = self.create()
        controller.teamProfileController = self
        return controller
    }()
    
    lazy var controllers: [UIViewController] = {
        return [
            self.postingsViewController,
            self.mapViewController,
            self.infoViewController,
            self.challengesViewController,
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if team == nil {
            if let partialTeam = partialTeam {
                partialTeam.fetch().onSuccess { team in
                    self.team = team
                    self.title = team.name
                    self.hasChanged()
                }
            } else {
                // Create menu buttons for navigation item
                let barButtonImage = UIImage(named: "menu_Icon_white")
                if barButtonImage != nil {
                    self.addLeftBarButtonWithImage(barButtonImage!)
                }
                
                Team.team(with: CurrentUser.shared.currentTeamId(), in: CurrentUser.shared.currentEventId()).onSuccess { team in
                    self.team = team
                    self.title = team.name
                    self.hasChanged()
                }
            }
        }
        
        title = team?.name
        
        extendedLayoutIncludesOpaqueBars = true
        
        subMenu.backgroundColor = .white
        dataSource = self
        delegate = self
        
        // Style the navigation bar
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = .mainOrange
        self.navigationController!.navigationBar.backgroundColor = .mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.subMenuSelectionBarView.frame.origin.x = 0.0
        self.subMenuSelectionBarView.frame.origin.y = self.postingsButton.frame.size.height + 8.0
        self.subMenuSelectionBarView.frame.size.height = 2.0
        self.subMenuSelectionBarView.backgroundColor = .mainOrange
        self.subMenu.addSubview(self.subMenuSelectionBarView)
        
        self.subMenu.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        
        self.select(button: postingsButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !animated {
            hasChanged(showNavbar: previousConstant < 0)
        } else {
            if wasLoadedBefore {
                if currentIndex == 0 {
                    // Now comes the fucked up autolayout part
                    buttonsToTopConstraint.constant -= barHeight
                    view.layoutIfNeeded()
                    if previousConstant > 0 {
                        hasChanged(showNavbar: false)
                        hasScrolled(to: postingsViewController.tableView.contentOffset.y + barHeight)
                    } else {
                        barHeight = 0
                    }
                    view.layoutIfNeeded()
                }
            } else {
                hasChanged(showNavbar: false)
            }
        }
        wasLoadedBefore = true
    }
    
    @IBAction func didPressButton(_ sender: UIButton) {
        guard let index = buttons.index(of: sender) else {
            return
        }
        self.scrollToPage(.atIndex(index: index), animated: true)
    }

}

extension TeamViewController {
    
    var buttons: [UIButton] {
        return [
            postingsButton,
            mapButton,
            infoButton,
            challengesButton,
            sponsorsButton
        ]
    }
    
    func selectButton(at index: Int) {
        select(button: buttons[index])
        setButtonColors()
        animateSubMenuSelectionBarView(to: buttons[index])
    }
    
    func select(button: UIButton) {
        self.deselectAllSubMenuButtons()
        button.isSelected = true
    }
    
    func deselectAllSubMenuButtons() {
        buttons.forEach {
            $0.isSelected = false
        }
    }
    
    func animateSubMenuSelectionBarView(to button: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.subMenuSelectionBarView.frame.origin.x = button.frame.origin.x
            self.subMenuSelectionBarView.frame.size.width = button.frame.size.width
        }
    }
    
}

extension TeamViewController: PageboyViewControllerDataSource {
    
    func viewControllers(forPageboyViewController pageboyViewController: PageboyViewController) -> [UIViewController]? {
        
        return controllers
    }
    
    func defaultPageIndex(forPageboyViewController pageboyViewController: PageboyViewController) -> PageboyViewController.PageIndex? {
        
        return nil
    }
    
}

extension TeamViewController: PageboyViewControllerDelegate {
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollToPageAtIndex index: Int, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        
        selectButton(at: index)
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, willScrollToPageAtIndex index: Int, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        
        selectButton(at: index)
        if index != 0 {
            hasCurrentPosition(at: 0)
        } else {
            let offset = postingsViewController.tableView.contentOffset.y
            hasCurrentPosition(at: offset)
        }
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollToPosition position: CGPoint, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        
        /// Do nothing
    }
    
}

extension TeamViewController {
    
    func hasScrolled(to offset: CGFloat) {
        let constant = -offset - subMenu.frame.height - UIApplication.shared.statusBarFrame.height
        self.buttonsToTopConstraint.constant = max(constant, barHeight)
        if previousConstant > 0 && constant <= 0 {
            hasChanged(showNavbar: true)
        }
        if previousConstant <= 0 && constant > 0 {
            hasChanged(showNavbar: false)
        }
        previousConstant = constant
    }
    
    func hasCurrentPosition(at offset: CGFloat) {
        let constant = -offset - subMenu.frame.height - UIApplication.shared.statusBarFrame.height
        if previousConstant > 0 && constant <= 0 {
            previousConstant = constant
            hasChanged(showNavbar: true, includeConstant: true)
        } else if previousConstant <= 0 && constant > 0 {
            previousConstant = constant
            hasChanged(showNavbar: false, includeConstant: true)
        } else {
            previousConstant = constant
        }
    }
    
}

extension TeamViewController {
    
    func setButtonColors(selectedColor: UIColor, unselectedColor: UIColor) {
        self.buttons.forEach { button in
            button.set(color: button.isSelected ? selectedColor : unselectedColor)
        }
    }
    
    func setButtonColors() {
        let showNavbar = previousConstant <= 0
        let selectedColor: UIColor = showNavbar ? .mainOrange : .white
        let color: UIColor = showNavbar ? .lightGray : .white
        UIView.animate(withDuration: 0.3) {
            self.setButtonColors(selectedColor: selectedColor, unselectedColor: color)
        }
    }
    
    func hasChanged(showNavbar: Bool, includeConstant: Bool = false) {
        let alpha: CGFloat = showNavbar ? 1.0 : 0
        let selectedColor: UIColor = showNavbar ? .mainOrange : .white
        let color: UIColor = showNavbar ? .lightGray : .white
        let menuBorder: CGFloat = showNavbar ? 1.0 : 0.0
        barHeight = self.navigationController?.navigationBar.frame.height ?? 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.setButtonColors(selectedColor: selectedColor, unselectedColor: color)
            self.subMenu.backgroundColor = self.subMenu.backgroundColor?.withAlphaComponent(alpha)
            self.subMenu.layer.borderWidth = menuBorder
            self.subMenuSelectionBarView.backgroundColor = selectedColor
            if includeConstant && self.navigationController?.navigationBar.alpha != alpha {
                self.buttonsToTopConstraint.constant = max(self.previousConstant, 0)
            }
            self.navigationController?.navigationBar.alpha = alpha
            self.view.layoutIfNeeded()
        }
    }
    
}
