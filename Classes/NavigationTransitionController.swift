//
//  NavigationController.swift
//  NavigationTransitionController
//
//  Created by Joshua Choi on 11/26/20.
//  Copyright © 2020 Joshua Choi. All rights reserved.
//

import UIKit



// MARK: - UIViewController
extension UIViewController {
    /// Returns the view controller's NavigationTransitionController object
    var navigationTransitionController: NavigationTransitionController? {
        return self.navigationController as? NavigationTransitionController
    }
}



// MARK: - UIApplication
extension UIApplication {
    /// Get the application's key window based on the current scene
    static var keyWindow = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first ?? UIApplication.shared.windows.filter({$0.isKeyWindow}).first
    
    /// Get the top view controller presented in the app
    static var topViewController: UIViewController? {
        get {
            // Store the application's key window's root view controller
            var topViewController = UIApplication.keyWindow?.rootViewController
            
            // Recursively iterate through the navigation stack until we've reached the end
            while let presentedViewController = topViewController?.presentedViewController {
                topViewController = presentedViewController
            }
            
            // Return the top view controller
            return topViewController
        }
    }
}



/**
 Abstract: A custom UINavigationController class that adopts the UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning, and UIViewControllerAnimatedTransitioning protocols to animate the transitions of the presentation and dismissal of a view controller. The problem with general navigation operations using the UINavigationController is animating the transition when pushing or popping a view controller off the navigation stack. However, the problem with this is that its UINavigationBar object becomes incredibly difficult to customize as well as manage when re-setting a view controller's navigation bar (i.e., resetting the navigation bar in the view controller's ```viewDidAppear``` lifecycle. This NavigationTransitionController class presents and dismisses from any given view controller by initializing its root view controller and then presenting or dismissing it.
 */
public class NavigationTransitionController: UINavigationController {
    
    // MARK: - Class Vars
    
    // MARK: - NavigationTransitionType
    var type: NavigationTransitionType!
    
    // MARK: - NavigationTransitionOperation
    var navigationTransitionOperation: NavigationTransitionOperation = .present
    
    // MARK: - UIViewControllerContextTransitioning
    var transitionContext: UIViewControllerContextTransitioning!
    
    // MARK: - TimeInterval
    let animationDuration = TimeInterval(0.2)
    
    // MARK: - UIViewController
    var rootViewController, viewController: UIViewController!
    
    // MARK: - UIPercentDrivenInteractiveTransition
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    
    /// Initialized Boolean used to determine if we're interactively driving the transitions
    var isInteractivelyDriven: Bool = false
    
    // MARK: - UIPanGestureRecognizer
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    /// Initialized UIView objects representing the initial and final views when transitioning between presenting a photo or video and dismissing a photo or video
    var initialView: UIView?, finalView: UIView?
    
    /// Initialized UIView object representing the background transition when presenting or dismissing view controllers
    var backgroundView: UIView?
    
    /// Initialized UIView object representing the current view in the UIViewControllerContextTransitioning object's container view when presenting or dismissing a photo or video
    var contextView: UIView?
    
    /// Square rect centered in the screen
    let centerFrame: CGRect = CGRect(x: 0.0, y: UIScreen.main.bounds.midY - (UIScreen.main.bounds.width/2.0), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
    
    /// Closure called whenever this class' UIPanGestureRecognizer is interactively transitioning
    var interactiveTransitioningObserver: ((_ state: UIGestureRecognizer.State) -> Void)? = nil
    
    /// MARK: - Init
    /// - Parameter rootViewController: The root view controller for this navigation controller.
    /// - Parameter type: A NavigationTransitionType enum used to specify the transition style.
    /// - Parameter initialView: An optional UIView object used to transition between view controllers when presenting particular photos or videos like the stock gallery app
    /// - Parameter finalView: An optional UIView object used to transition between view controllers when dismissing particular photos or videos like the stock gallery app
    public init(rootViewController: UIViewController,
                type: NavigationTransitionType = NavigationTransitionType.standard,
                initialView: UIView? = nil,
                finalView: UIView? = nil) {
        super.init(rootViewController: rootViewController)
        
        // MARK: - UIViewController
        self.rootViewController = rootViewController
        
        // MARK: - NavigationTransitionType
        self.type = type
        
        // MARK: - UIView
        self.initialView = initialView
        
        // MARK: - UIView
        self.finalView = finalView
        
        // MARK: - UIViewControllerTransitioningDelegate
        self.rootViewController.providesPresentationContextTransitionStyle = true
        self.rootViewController.modalPresentationStyle = .overFullScreen
        self.rootViewController.transitioningDelegate = self

        // Setup this navigation controller
        self.modalPresentationStyle = .overFullScreen
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Presents this class' navigation controller and its root view controller over another view controller
    /// - Parameters:
    ///   - viewController: A UIViewController referencing which view controller this navigation controller and its root view controller should be presented over
    ///   - completion: Returns a Boolean value if the presentation was successful
    public func presentNavigation(_ viewController: UIViewController?, completion: ((_ success: Bool) -> ())? = nil) {
        // Unwrap the view controller
        guard let viewController = viewController else {
            print("\(#file)/\(#line) - Couldn't unwrap the UIViewController")
            // Pass the values in the completion handler
            completion?(false)
            return
        }
        
        // MARK: - UIPanGestureRecognizer
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        self.panGestureRecognizer.maximumNumberOfTouches = 1
        self.panGestureRecognizer.delegate = self
        self.rootViewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.rootViewController.view.addGestureRecognizer(self.panGestureRecognizer)

        // Store the view controller
        self.viewController = viewController
        
        // Update this class' NavigationTransitionOperation
        self.navigationTransitionOperation = .present
        
        // Call the view controller's life cycle
        viewController.viewWillDisappear(true)
        
        // Configure the view controller that's about to present this navigation controller class
        viewController.transitioningDelegate = self
        viewController.present(self, animated: true) {
            // Update this class' NavigationTransitionOperation
            self.navigationTransitionOperation = .dismiss
            
            // Call the view controller's life cycle
            viewController.viewDidDisappear(true)
            
            // Pass the values in the completion handler
            completion?(true)
        }
    }
    
    /// Dismisses the view controller and its navigation controller
    /// - Parameter completion: Returns a Boolean indicating whether the dismissal completed
    public func dismissNavigation(completion: ((_ success: Bool) -> ())? = nil) {
        // Update this class' NavigationTransitionOperation
        self.navigationTransitionOperation = .dismiss
        
        // MARK: - UIViewController
        let underlyingViewController: UIViewController? = presentingViewController
        
        // Dismiss this view controller class
        self.dismiss(animated: true) {
            
            // MARK: - UINavigationController
            // Only call the view controller's life cycle if the underlying view controller is the application's top view controller
            if let navigationController = underlyingViewController as? UINavigationController, UIApplication.topViewController == underlyingViewController {
                // MARK: - UINavigationController
                navigationController.childViewControllers.first?.viewWillAppear(true)
                navigationController.childViewControllers.first?.viewDidAppear(true)

            } else if UIApplication.topViewController == underlyingViewController {
                // MARK: - UIViewController
                underlyingViewController?.viewWillAppear(true)
                underlyingViewController?.viewDidAppear(true)
            }
            
            // Pass the values in the completion handler
            completion?(true)
        }
    }
}


