//
//  ViewController.swift
//  NavigationTransitionController
//
//  Created by HackShitUp on 12/19/2020.
//  Copyright (c) 2020 HackShitUp. All rights reserved.
//

import UIKit
import NavigationTransitionController


class ToViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green

        let tap = UITapGestureRecognizer(target: self, action: #selector(loadToVC(_:)))
        tap.numberOfTapsRequired = 1
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
    }

    @objc fileprivate func loadToVC(_ sender: Any) {
        // MARK: - ToViewController
        let toVC = ToViewController()
        // MARK: - NavigationTransitionController
        let navigationTransitionController = NavigationTransitionController(rootViewController: toVC)
        navigationTransitionController.presentNavigation(self)
    }
}

