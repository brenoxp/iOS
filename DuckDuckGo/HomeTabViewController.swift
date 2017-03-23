//
//  HomeTabViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 27/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class HomeTabViewController: UIViewController, Tab {
    
    @IBOutlet weak var tabIcon: UIButton!
    @IBOutlet weak var passiveContainerView: UIView!
    @IBOutlet weak var centreBar: UIView!
    @IBOutlet weak var miniOnboardingContainer: UIView!
    @IBOutlet weak var onboardingBottomConstraint: NSLayoutConstraint!
    
    var onboardingController: OnboardingViewController?
    
    weak var tabDelegate: HomeTabDelegate?
    
    let omniBarStyle: OmniBar.Style = .home
    let showsUrlInOmniBar = false
    
    var name: String? = UserText.homeLinkTitle
    var url: URL? = URL(string: AppUrls.base)!
    var favicon: URL? = URL(string: AppUrls.favicon)
    
    var canGoBack = false
    var canGoForward: Bool = false
    
    private var activeMode = false
    private lazy var tabIconMaker = TabIconMaker()
    
    static func loadFromStoryboard() -> HomeTabViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabViewController") as! HomeTabViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if UIApplication.shared.statusBarOrientation.isLandscape, traitCollection.verticalSizeClass == .compact{
                onboardingBottomConstraint.constant = 0
            } else {
                onboardingBottomConstraint.constant = keyboardSize.height
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetNavigationBar()
        activeMode = false
        refreshMode()
        refreshTabIcon()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissMiniOnboardingFlow()
    }
    
    private func resetNavigationBar() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.isToolbarHidden = true
        navigationController?.hidesBarsOnSwipe = false
    }
    
    private func refreshMode() {
        if activeMode {
            enterActiveMode()
        } else {
            enterPassiveMode()
        }
    }
    
    private func refreshTabIcon() {
        guard let count = tabDelegate?.homeTabDidRequestTabCount(homeTab: self) else { return }
        if count > 1 {
            let image = tabIconMaker.icon(forTabs: count)
            tabIcon.setImage(image, for: .normal)
        }
    }
    
    @IBAction func onEnterActiveModeTapped(_ sender: Any) {
        enterActiveMode()
    }
    
    @IBAction func onEnterPassiveModeTapped(_ sender: Any) {
        enterPassiveMode()
    }
    
    @IBAction func onTabButtonPressed(_ sender: UIButton) {
        tabDelegate?.homeTabDidRequestTabsSwitcher(homeTab: self)
    }
    
    @IBAction func onBookmarksButtonPressed(_ sender: UIButton) {
        tabDelegate?.homeTabDidRequestBookmarks(homeTab: self)
    }
    
    func enterPassiveMode() {
        navigationController?.isNavigationBarHidden = true
        passiveContainerView.isHidden = false
        dismissMiniOnboardingFlow()
        tabDelegate?.homeTabDidDeactivateOmniBar(homeTab: self)
    }
    
    func enterActiveMode() {
        navigationController?.isNavigationBarHidden = false
        passiveContainerView.isHidden = true
        showMiniOnboardingFlow()
        tabDelegate?.homeTabDidActivateOmniBar(homeTab: self)
    }
    
    private func showMiniOnboardingFlow() {
        let onboardingController = OnboardingViewController.loadFromStoryboard(size: .mini, doneButtonStyle: nil)
        self.onboardingController = onboardingController
        addChildViewController(onboardingController)
        onboardingController.view.frame = miniOnboardingContainer.frame
        miniOnboardingContainer.addSubview(onboardingController.view)
        miniOnboardingContainer.isHidden = false
    }
    
    private func dismissMiniOnboardingFlow() {
        miniOnboardingContainer.isHidden = true
        onboardingController?.removeFromParentViewController()
        miniOnboardingContainer.clearSubviews()
        onboardingController = nil
    }
    
    func load(url: URL) {
        tabDelegate?.homeTab(self, didRequestUrl: url)
    }
    
    func goBack() {}
    
    func goForward() {}
    
    func reload() {}
    
    func dismiss() {
        removeFromParentViewController()
        view.removeFromSuperview()
    }
    
    func destroy() {
        dismiss()
    }
    
    func omniBarWasDismissed() {
        enterPassiveMode()
    }
}