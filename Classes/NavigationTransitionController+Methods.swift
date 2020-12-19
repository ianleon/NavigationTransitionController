//
//  NavigationTransitionController+Methods.swift
//  NavigationTransitionController
//
//  Created by Joshua Choi on 11/27/20.
//  Copyright © 2020 Joshua Choi. All rights reserved.
//

import UIKit



/**
 Abstract: Custom sourcefile used to accomodate the NavigationTransitionController class with key methods
 - updateInitialView
 - updateFinalView
 - handlePanGestureRecognizer
 - applyPresentationTransition
 - applyDismissalTransition
 */
extension NavigationTransitionController {
    /// Updates the NavigationTransitionController's ```initialView``` object to hide/show when presenting or dismissing this navigation controller class
    /// - Parameter view: An optional UIView object
    @objc func updateInitialView(_ view: UIView?) {
        // Update this class' ```initialView```
        self.initialView = view
    }
    
    /// Updates the NavigationTransitionController's ```finalView``` object to hide/show when presenting or dismissing this navigation controller class
    /// - Parameter view: An optional UIView object
    @objc func updateFinalView(_ view: UIView?) {
        // Update this class' ```finalView```
        self.finalView = view
    }
    
    /// Handle the pan gesture recognizer for the view controller at the top of the navigation stack
    /// - Parameter gesture: A UIPanGestureRecognzier object that calls this method
    @objc func handlePanGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
        // Update the Boolean to indicate that we're interactively driving the transition animations
        self.isInteractivelyDriven = gesture.state == .began || gesture.state == .changed
        
        // Call the closure to indicate that the transition is changing
        self.interactiveTransitioningObserver?(gesture.state)
        
        // Get the pan gesture's velocity
        let velocity = gesture.velocity(in: nil)
        
        // Get the pan gesture's translation
        let translation = gesture.translation(in: nil)
                
        // CGFloat value representing a gesture's "flick"
        let flickMagnitude: CGFloat = 900.0
        
        // Determine if we're flicking the view
        let isFlick = (velocity.vector.magnitude > flickMagnitude)
        
        // MARK: - NavigationTransitionType
        switch type {
        case .standard:
            switch gesture.state {
            case .began:
                // MARK: - UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
                rootViewController.navigationTransitionController?.dismissNavigation()
            
            case .changed:
                // Define the percentage by computing the ratio between the gesture's current translation and its maximium allowed translation
                let percentage = translation.x/UIScreen.main.bounds.width
                // MARK: UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition?.update(percentage)
            default:
                // If we've reached the parameters at which we should cancel the interactive transition driver, then indicate that it's finished and de-allocate the driver object
                guard velocity.x > 0.0 && (translation.x >= UIScreen.main.bounds.width/3.0 || isFlick == true) else {
                    // MARK: - UIPercentDrivenInteractiveTransition
                    percentDrivenInteractiveTransition?.cancel()
                    return
                }
                // MARK: - UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition?.finish()
                percentDrivenInteractiveTransition = nil
            }
            
        case .presentation:
            switch gesture.state {
            case .began:
                // MARK: - UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
                rootViewController.navigationTransitionController?.dismissNavigation()
                
                // MARK: - UIScrollView
                // Disable the scroll view when the gesture begins
                if let scrollView = gesture.view?.subviews.filter({$0.isKind(of: UIScrollView.self) == true}).first as? UIScrollView {
                    scrollView.isScrollEnabled = false
                }
                
            case .changed:
                // Define the percentage by computing the ratio between the gesture's current translation and its maximium allowed translation
                let percentage = translation.y/UIScreen.main.bounds.height
                // MARK: UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition?.update(percentage)
            default:
                // MARK: - UIScrollView
                // Re-enable the scroll view whens the gesture ends
                if let scrollView = gesture.view?.subviews.filter({$0.isKind(of: UIScrollView.self) == true}).first as? UIScrollView {
                    scrollView.isScrollEnabled = true
                }
                
                // If we've reached the parameters at which we should cancel the interactive transition driver, then indicate that it's finished and de-allocate the driver object
                guard velocity.y > 0.0 && (translation.y >= UIScreen.main.bounds.height/3.0 || isFlick == true) else {
                    // MARK: - UIPercentDrivenInteractiveTransition
                    percentDrivenInteractiveTransition?.cancel()
                    return
                }
                // MARK: - UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition?.finish()
                percentDrivenInteractiveTransition = nil
            }
            
        case .zoom:
            switch gesture.state {
            case .began:
                // MARK: - UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
                rootViewController.navigationTransitionController?.dismissNavigation()

            case .changed:
                // Calculate the percentage by providing the range for how much the translation is allowed
                let percentage = CGFloat.scaleAndShift(value: translation.y, inRange: (min: 0.0, max: 200.0))
                
                // Calculate the scale of the context view and set its minimum scale to be as as small as 60%
                let scale = 1.0 - (1.0 - CGFloat(0.60)) * percentage
                
                // MARK: UIPercentDrivenInteractiveTransition
                percentDrivenInteractiveTransition?.update(percentage)
                
                // Animate the context view
                self.contextView?.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale).translatedBy(x: translation.x, y: translation.y)
                
            default:
                // Rest the gesture's translation
                gesture.setTranslation(.zero, in: nil)
                
                // If we've reached the parameters at which we should cancel the interactive transition driver, then indicate that it's finished and de-allocate the driver object
                switch velocity.y > 0.0 && (translation.y >= UIScreen.main.bounds.height/3.0 || isFlick == true) {
                case true:
                    // Calculate the initial view's frame for the transition
                    let initialViewFrame = self.initialView?.superview?.convert(self.initialView?.frame ?? self.centerFrame, to: transitionContext.containerView) ?? self.centerFrame

                    // Apply the animations
                    UIView.animate(withDuration: animationDuration) {
                        self.contextView?.frame = initialViewFrame
                    } completion: { (success: Bool) in
                        // MARK: - UIPercentDrivenInteractiveTransition
                        self.percentDrivenInteractiveTransition?.finish()
                        self.percentDrivenInteractiveTransition = nil
                    }
                    
                case false:
                    // Calculate the final view's frame
                    let finalViewFrame = self.finalView?.superview?.convert(self.finalView?.frame ?? self.centerFrame, to: transitionContext.containerView) ?? self.centerFrame

                    // Reset the context view to match that of the final view's frame
                    UIView.animate(withDuration: animationDuration) {
                        self.contextView?.frame = finalViewFrame
                    } completion: { (success: Bool) in
                        // MARK: - UIPercentDrivenInteractiveTransition
                        self.percentDrivenInteractiveTransition?.cancel()
                    }
                }
            }
            
        default: break;
        }
    }
    
    /// Apply the presentation animation transition
    /// - Parameter transitionContext: A UIViewControllerContextTransitioning object
    func applyPresentationTransition(transitionContext: UIViewControllerContextTransitioning) {
        // MARK: - UIViewController
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            print("\(#file)/\(#line) - Couldn't unwrap the transition context's to view controller")
            // Indicate that the transition context wasn't completed
            transitionContext.completeTransition(false)
            return
        }
        
        // Add the fromViewController and toViewController's view to the transition context's container view
        transitionContext.containerView.addSubview(toViewController.view)
        
        // MARK: - NavigationTransitionType
        switch type {
        case .fade:
            // Setup the initial states
            toViewController.view.alpha = 0.0
            
            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                toViewController.view.alpha = 1.0
            } completion: { (success: Bool) in
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        
        case .standard:
            // Setup the initial states
            toViewController.view.frame.origin.x = UIScreen.main.bounds.width
            
            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                toViewController.view.frame.origin.x = 0.0
            } completion: { (success: Bool) in
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
        case .presentation:
            // Setup the initial states
            toViewController.view.frame.origin.y = UIScreen.main.bounds.height
            toViewController.view.layer.addShadow(color: UIColor.lightGray.cgColor)
            toViewController.view.layer.shadowColor = UIColor.lightGray.cgColor
            toViewController.view.layer.shadowOpacity = 0.5
            toViewController.view.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
            toViewController.view.layer.shadowRadius = 4.0
            toViewController.view.layer.masksToBounds = false

            // MARK: - UIView
            self.backgroundView = UIView(frame: UIScreen.main.bounds)
            self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            transitionContext.containerView.insertSubview(self.backgroundView!, belowSubview: toViewController.view)
            
            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(1.0)
                toViewController.view.frame.origin.y = 0.0
            } completion: { (success: Bool) in
                // Remove the background view
                self.backgroundView?.removeFromSuperview()
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
        case .zoom:
            // Compute the initial view's frame relative to the transition context's container view
            let initialViewFrame: CGRect = self.initialView?.superview?.convert(self.initialView?.frame ?? self.centerFrame, to: transitionContext.containerView) ?? self.centerFrame
            
            // Compute the final frames for the transition
            let expectedWidth = UIScreen.main.bounds.width
            let expectedHeight = (UIScreen.main.bounds.width/initialViewFrame.width) * initialViewFrame.height == 0.0 ? UIScreen.main.bounds.width : ((UIScreen.main.bounds.width/initialViewFrame.width) * initialViewFrame.height)
            
            // MARK: - UIView
            self.backgroundView = UIView(frame: UIScreen.main.bounds)
            self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            transitionContext.containerView.insertSubview(self.backgroundView!, belowSubview: toViewController.view)
            
            // MARK: - UIView
            self.contextView = self.initialView?.snapshotView(afterScreenUpdates: false)
            if self.contextView != nil {
                transitionContext.containerView.insertSubview(self.contextView!, belowSubview: toViewController.view)
                self.contextView?.frame = initialViewFrame
            }
                        
            // Initially, hide the initialView and the toViewController's view
            self.initialView?.alpha = 0.0
            toViewController.view.alpha = 0.0
            
            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(1.0)
                self.contextView?.frame.size.width = expectedWidth
                self.contextView?.frame.size.height = expectedHeight
                self.contextView?.center = CGPoint(x: UIScreen.main.bounds.width/2.0, y: UIScreen.main.bounds.height/2.0)

            } completion: { (success: Bool) in
                // Show the toViewController's view and the initialView
                toViewController.view.alpha = 1.0
                self.initialView?.alpha = 1.0
                // Remove the background view and context view from their superviews
                self.backgroundView?.removeFromSuperview()
                self.contextView?.removeFromSuperview()
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
        default: break;
        }
    }
    
    /// Apply the dismissal animation transition by removing the fromViewController's view from the transition context's container view
    /// - Parameter transitionContext: A UIViewControllerContextTransitioning object
    func applyDismissalTransition(transitionContext: UIViewControllerContextTransitioning) {
        // MARK: - UIViewController
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            print("\(#file)/\(#line) - Couldn't unwrap the transition context's from view controller")
            // Indicate that the transition context wasn't completed
            transitionContext.completeTransition(false)
            return
        }
        
        // MARK: - NavigationTransitionType
        switch type {
        case .fade:
            // Setup the initial states
            fromViewController.view.alpha = 1.0
            
            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                fromViewController.view.alpha = 0.0
            } completion: { (success: Bool) in
                // Only remove the fromViewController's view from its superview when the transition context was cancelled
                if !transitionContext.transitionWasCancelled {
                    fromViewController.view.removeFromSuperview()
                }
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        
        case .standard:
            // Setup the initial states
            fromViewController.view.frame.origin.x = 0.0
            fromViewController.view.layer.shadowColor = UIColor.lightGray.cgColor
            fromViewController.view.layer.shadowOpacity = 0.5
            fromViewController.view.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
            fromViewController.view.layer.shadowRadius = 4.0
            fromViewController.view.layer.masksToBounds = false
            
            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                fromViewController.view.frame.origin.x = UIScreen.main.bounds.width
            } completion: { (success: Bool) in
                // Only remove the fromViewController's view from its superview when the transition context was cancelled
                if !transitionContext.transitionWasCancelled {
                    fromViewController.view.removeFromSuperview()
                }
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }

        case .presentation:
            // Setup the initial states
            fromViewController.view.frame.origin.y = 0.0
            
            // MARK: - UIView
            self.backgroundView = UIView(frame: UIScreen.main.bounds)
            self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(1.0)
            transitionContext.containerView.insertSubview(self.backgroundView!, belowSubview: fromViewController.view)
            
            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                fromViewController.view.frame.origin.y = UIScreen.main.bounds.height
            } completion: { (success: Bool) in
                // Remove the background view
                self.backgroundView?.removeFromSuperview()
                // Only remove the fromViewController's view from its superview when the transition context was cancelled
                if !transitionContext.transitionWasCancelled {
                    fromViewController.view.removeFromSuperview()
                }
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
        case .zoom:
            // Calculate the initial view's frame for the transition
            let initialViewFrame = self.initialView?.superview?.convert(self.initialView?.frame ?? self.centerFrame, to: fromViewController.view) ?? self.centerFrame
            
            // Calculate the final view's frame for the transition
            let finalViewFrame = self.finalView?.superview?.convert(self.finalView?.frame ?? self.centerFrame, to: fromViewController.view) ?? self.centerFrame

            // MARK: - UIView
            self.backgroundView = UIView(frame: UIScreen.main.bounds)
            self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(1.0)
            transitionContext.containerView.addSubview(self.backgroundView!)

            // MARK: - UIView
            // Set the context view to be the final view and fallback to the initial view if the final view doesn't exist
            self.contextView = self.finalView?.snapshotView(afterScreenUpdates: false) ?? self.initialView?.snapshotView(afterScreenUpdates: false)
            if self.contextView != nil {
                transitionContext.containerView.addSubview(self.contextView!)
                self.contextView?.transform = CGAffineTransform.identity
                self.contextView?.frame = self.finalView != nil ? finalViewFrame : CGRect(x: 0.0, y: UIScreen.main.bounds.midY - (UIScreen.main.bounds.width/2.0), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            }

            // Initially, hide the initialView and the fromViewController's view
            self.initialView?.alpha = 0.0
            fromViewController.view.alpha = 0.0

            // Apply the animations
            UIView.animate(withDuration: animationDuration) {
                self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                if !self.isInteractivelyDriven {
                    self.contextView?.frame = initialViewFrame
                }
            } completion: { (success: Bool) in
                // Show the initial view
                self.initialView?.alpha = 1.0
                
                // Remove the background view and context view from their superviews
                self.backgroundView?.removeFromSuperview()
                self.contextView?.removeFromSuperview()
                
                // Only remove the fromViewController's view from its superview when the transition context was cancelled — otherwise, show the from view controller's view
                if !transitionContext.transitionWasCancelled {
                    fromViewController.view.removeFromSuperview()
                } else {
                    fromViewController.view.alpha = 1.0
                }
                
                // MARK: - UIViewControllerContextTransitioning
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        default: break;
        }

    }
}
