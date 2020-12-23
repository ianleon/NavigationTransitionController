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
            
//            transitionFinal.widthAnchor.constraint(equalTo: view.widthAnchor),
//            transitionFinal.heightAnchor.constraint(equalTo: view.widthAnchor),
            
            // Issue here
            // Dismissing looks fine
            transitionFinal.widthAnchor.constraint(equalToConstant: 150),
            transitionFinal.heightAnchor.constraint(equalToConstant: 150)
        ])
        
    }
}

class ViewController: UIViewController {

    let transitionInitial = UIView(frame: .zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5

        let tap = UITapGestureRecognizer(target: self, action: #selector(loadToVC(_:)))
        tap.numberOfTapsRequired = 1
        view.isUserInteractionEnabled = true
        
        let listStack = UIStackView(frame: .zero)
        listStack.alignment = .leading
        listStack.axis = .vertical
        listStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listStack)
        
        listStack.addArrangedSubview(transitionInitial)
        
        let makeTrig = {
            (title: String, action: Selector) -> UIButton in
            
            let button = UIButton(type: .system)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: action, for: .touchUpInside)

            return button
        }
        
        for trigger in [
            
            makeTrig("Standard", #selector(loadWithStandard)),
            makeTrig("Presentation", #selector(loadWithPresentation)),
            makeTrig("Zoom", #selector(loadWithZoom)),
            makeTrig("Fade", #selector(loadWithFade))
        ] {
            listStack.addArrangedSubview(trigger)
        }
        
        transitionInitial.translatesAutoresizingMaskIntoConstraints = false
        transitionInitial.backgroundColor = .systemRed
        
        NSLayoutConstraint.activate([
            transitionInitial.widthAnchor.constraint(equalToConstant: 44),
            transitionInitial.heightAnchor.constraint(equalToConstant: 44),
            listStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            listStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])

        
    }
    
    @objc func loadWithZoom() {
        
        let toVC = ToViewController()
        let nvtc = NavigationTransitionController(
            rootViewController: toVC,
            type: .zoom,
            initialView: transitionInitial,
            finalView: toVC.transitionFinal
        )
        // TODO cannot be dismissed by swiping up
        // Probably because swiping up in the app is used for comments
        
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
        // NOTE this transition cannot be dismissed with a gesture
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
        // NOTE disimissing requires a flick
        // Swiping all the way to the end and letting go will not trigger dismiss
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

