//
//  iOS+Extension.swift
//  NavigationTransitionController
//
//  Created by Joshua Choi on 12/18/20.
//

import UIKit

// MARK: - CALayer
extension CALayer {
    /// Adds a shadow to a CAlayer (usually of a UIView object).
    /// - Parameter color: A CGColor value represneting the shadow's color. Defaults to UIColor.black
    /// - Parameter opacity: A Float value representing the shadow's opacity. Defaults to 0.5
    /// - Parameter offset: A CGSize value representing the shadow's blur. Defaults to CGSize(width: 0, height: 4)
    /// - Parameter radius: A CGSize value representing the shadow's radius. Defaults to CGFloat(4.0)
    /// - Parameter masksToBounds: An optional Boolean value used to determine whether the view's sublayers should clip to their superlayer's bounds. If nil, the layer's masksToBounds property will be set to FALSE. Defaults to false.
    func addShadow(
        color: CGColor = UIColor.black.cgColor,
        opacity: Float = 0.5,
        offset: CGSize = CGSize(width: 0, height: 4),
        radius: CGFloat = 4,
        masksToBounds: Bool = false
        ) {
        
        self.shadowColor = color
        self.shadowOpacity = opacity
        self.shadowOffset = offset
        self.shadowRadius = radius
        self.masksToBounds = masksToBounds
    }
}



// MARK: - String
extension String {
    /// Determines if String value has NO String INCLUDING new lines and spaces.
    var isBlank: Bool {
        get {
            return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
        }
    }
}



// MARK: - UIApplication
extension UIApplication {
    /// Gets and returns the appropriate UIScene's UIWindow's UIEdgeInsets for the device's safe area, if there's any
    static var safeAreaInsets: UIEdgeInsets {
        get {
            if #available(iOS 11.0, *) {
                return UIApplication.topViewController?.view?.window?.safeAreaInsets ?? UIEdgeInsets.zero
            } else {
                return UIEdgeInsets.zero
            }
        }
    }
}
