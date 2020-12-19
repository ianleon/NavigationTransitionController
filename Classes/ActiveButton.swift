//
//  ActiveButton.swift
//  NavigationTransitionController
//
//  Created by Joshua Choi on 5/20/18.
//  Copyright © 2019 Nanogram, Inc. All rights reserved.
//

import UIKit

/**
 Abstract: UIButton sub-class that scales on touch.
 */
public class ActiveButton: UIButton {
    
    // MARK: - Class Vars
    
    /// Initialized Boolean value used to determine if this class should scale on touch
    var scaleOnTouch: Bool = true
    
    /// MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        frame = bounds
        translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topAnchor.constraint(equalTo: topAnchor).isActive = true
        trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    // MARK: - UITouch
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        scale(scaleOnTouch ? true : false)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        scale(scaleOnTouch ? true : false)
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        scale(false)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        scale(false)
    }
    
    /// Animates this view class based on the touch.
    /// - Parameter shouldShrink: A Boolean value that determines whether the view should shrink or grow
    func scale(_ shouldShrink: Bool) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: .beginFromCurrentState, animations: {
            self.transform = shouldShrink ? CGAffineTransform(scaleX: 0.90, y: 0.90) : CGAffineTransform.identity
        }, completion: nil)
    }
}
