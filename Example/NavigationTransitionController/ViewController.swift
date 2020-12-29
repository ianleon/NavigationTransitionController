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
    let transitionFinal = UIView(frame: .zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(transitionFinal)
        
        transitionFinal.translatesAutoresizingMaskIntoConstraints = false
        transitionFinal.backgroundColor = .systemRed
        NSLayoutConstraint.activate([
            transitionFinal.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            transitionFinal.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transitionFinal.widthAnchor.constraint(equalTo: view.widthAnchor),
            transitionFinal.heightAnchor.constraint(equalTo: view.widthAnchor),
        ])
    }
}

class ViewController: UIViewController {

    var transitionInitial:UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray5
        
        // Set up view to transition
        transitionInitial = UIView(frame: .init(x: 8, y: 70, width: 44, height: 44))
        transitionInitial.backgroundColor = .systemRed
        view.addSubview(transitionInitial)

        
        // Set up transition buttons
        let buttonStack = UIStackView(
            arrangedSubviews:
                [
                    ("Standard", #selector(loadWithStandard)),
                    ("Presentation", #selector(loadWithPresentation)),
                    ("Zoom", #selector(loadWithZoom)),
                    ("Fade", #selector(loadWithFade))
                ].map {
                    (title,action) -> UIButton in
            
                    let button = UIButton(type: .system)
                    
                    button.setTitle(title, for: .normal)
                    button.addTarget(self, action: action, for: .touchUpInside)

                    return button
                }
        )
        buttonStack.alignment = .leading
        buttonStack.distribution = .equalSpacing
        buttonStack.axis = .vertical
        buttonStack.frame = .init(x: 8, y: 140, width: 500, height: 150)
        view.addSubview(buttonStack)
    }
    
    @objc func loadWithZoom() {
        let toVC = ToViewController()
        let nvtc = NavigationTransitionController(
            rootViewController: toVC,
            type: .zoom,
            initialView: transitionInitial,
            finalView: toVC.transitionFinal
        )
        nvtc.presentNavigation(self)
    }
    
    @objc func loadWithFade() {
        let toVC = ToViewController()
        let nvtc = NavigationTransitionController(
            rootViewController: toVC,
            type: .fade
        )
        nvtc.presentNavigation(self)
    }
    
    @objc func loadWithPresentation() {
        let toVC = ToViewController()
        let nvtc = NavigationTransitionController(
            rootViewController: toVC,
            type: .presentation
        )
        nvtc.presentNavigation(self)
    }
    
    
    @objc func loadWithStandard() {
        let toVC = ToViewController()
        let nvtc = NavigationTransitionController(
            rootViewController: toVC,
            type: .standard,
            initialView: transitionInitial,
            finalView: toVC.transitionFinal
        )
        nvtc.presentNavigation(self)
    }

    @objc fileprivate func loadToVC(_ sender: Any) {
        // MARK: - ToViewController
        let toVC = ToViewController()
        // MARK: - NavigationTransitionController
        let navigationTransitionController = NavigationTransitionController(rootViewController: toVC)
        navigationTransitionController.presentNavigation(self)
    }
}

