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
        view.backgroundColor = .white
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5

        let tap = UITapGestureRecognizer(target: self, action: #selector(loadToVC(_:)))
        tap.numberOfTapsRequired = 1
        view.isUserInteractionEnabled = true
        
        let zoomButton = UIButton(type: .system)
        zoomButton.translatesAutoresizingMaskIntoConstraints = false
        zoomButton.setTitle("Zoom Transition", for: .normal)
        
        view.addSubview(zoomButton)
        
        NSLayoutConstraint.activate([
            zoomButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            zoomButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16)
        ])
        
        zoomButton.addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
    }

    @objc fileprivate func loadToVC(_ sender: Any) {
        // MARK: - ToViewController
        let toVC = ToViewController()
        // MARK: - NavigationTransitionController
        let navigationTransitionController = NavigationTransitionController(rootViewController: toVC)
        navigationTransitionController.presentNavigation(self)
    }
}

