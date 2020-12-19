//
//  NavigationBarItem.swift
//  Nanolens
//
//  Created by Joshua Choi on 11/19/20.
//  Copyright © 2020 Joshua Choi. All rights reserved.
//

import UIKit
import CoreData



/**
 Abstract: Custom UIView class
 */
public class NavigationBarItem: UIView {

    // MARK: - Class Vars
    
    /// A CGFloat value representing the default height of the bar button items in the navigation bar - defaults to 34.0
    static let height: CGFloat = 34.0
    
    /// CGRect value representing the default frame of the bar button item when it's displaying text
    static let titleFrame: CGRect = CGRect(x: 0, y: 0, width: NavigationBarItem.height * 2.0, height: NavigationBarItem.height)
    
    /// Initialized void function used as a closure
    @objc var method: (() -> Void)?
    
    // MARK: - ActiveButton
    var button: ActiveButton!
    
    // MARK: - UITapGestureRecognizer
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer!
    
    // - Tag
    public override var tintColor: UIColor! {
        didSet {
            DispatchQueue.main.async {
                // Set the tint color for this class' UIButton objects only
                self.subviews.forEach { (item: UIView) in
                    if item.isKind(of: UIButton.self) {
                        item.tintColor = self.tintColor
                    }
                }
            }
        }
    }
    
    /// MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    /// MARK: - Init
    /// - Parameter frame: A CGRect value used to specify the frame of this view class
    /// - Parameter type: An NavigationBarItemType enum
    /// - Parameter title: An optional NSAttributedString value representing the button's title
    /// - Parameter image: An optional UIImage value representing the UIButton's UIImage
    /// - Parameter imageContentMode: A UIView.ContentMode enum representing this class' ```imageView```'s cotnentMode property. Only used when this item type is equal to "image"
    /// - Parameter tintColor: An optional UIColor value representing the UIButton's tintColor
    /// - Parameter backgroundColor: An optional UIColor value used to set the background color of this view class` ```containerView```
    /// - Parameter cornerRadii: An optional CGFloat value representing the corner radius of this class' ```containerView```
    /// - Parameter offset: A CGFloat value representing the padding between the top, left, right, and bottom for the custom button or image view added to this view class. Defaults to 8.0
    /// - Parameter method:An optional closure called when this view class is tapped
    convenience init(frame: CGRect = CGRect(x: 0, y: 0, width: 34.00, height: 34.00),
                     title: NSAttributedString? = nil,
                     image: UIImage? = nil,
                     imageContentMode: UIView.ContentMode = .scaleAspectFill,
                     tintColor: UIColor = UIColor.black,
                     backgroundColor: UIColor? = .clear,
                     cornerRadii: CGFloat? = nil,
                     offset: CGFloat = 6.0,
                     method: (() -> Void)? = nil) {
        
        self.init(frame: frame)
        
        // Set the closure
        self.method = method

        // MARK: - ActiveButton
        button = ActiveButton(frame: CGRect(x: offset, y: offset, width: bounds.width - (offset * 2), height: bounds.height - (offset * 2)))
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setAttributedTitle(title, for: .normal)
        button.tintColor = .clear
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: offset).isActive = true
        button.topAnchor.constraint(equalTo: topAnchor, constant: offset).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -offset).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -offset).isActive = true
        
        // Setup this view class
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadii ?? 0.0
        self.clipsToBounds = false
        
        // Set this class' ```tintColor```
        self.tintColor = tintColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        frame = bounds
        backgroundColor = .clear
        clipsToBounds = false
        translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
        heightAnchor.constraint(equalToConstant: bounds.height).isActive = true
        
        // MARK: - UITapGestureRecognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(callToAction(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.cancelsTouchesInView = false
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    /// Called when this view class was tapped
    /// - Parameter sender: A UITapGestureRecognizer oject that calls this method
    @objc fileprivate func callToAction(_ sender: UITapGestureRecognizer) {
        // Call the closure
        self.method?()
    }
}
