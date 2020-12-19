//
//  NavigationBar.swift
//  Nanolens
//
//  Created by Joshua Choi on 11/18/20.
//  Copyright © 2020 Joshua Choi. All rights reserved.
//

import UIKit



// MARK: - NavigationTitleView
public class NavigationTitleView: UIView {
    public override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
}



// MARK: - NavigationBarTitleViewAlignment
enum NavigationBarTitleViewAlignment {
    case left
    case center
    case right
}



// MARK: - NavigationBarDelegate
@objc protocol NavigationBarDelegate {
    /// Called when the NavigationBar's TextField cleared
    /// - Parameter textField: A UITextField object that calls this method
    @objc optional func navigationBarTextFieldDidClear(_ textField: UITextField)
    /// Called when the NavigationBar's TextField hit the return key
    /// - Parameter textField: A UITextField object that calls this method
    @objc optional func navigationBarTextFieldDidReturn(_ textField: UITextField)
    /// Called when the NavigationBar's TextField updated its edits
    /// - Parameter textField: A UITextField object that calls this method
    @objc optional func navigationBarTextFieldUpdatedEdits(_ textField: UITextField)
    
}




/**
 Abstract: NSObject class that sets up a view controller's navigation bar
 */
public class NavigationBar: NSObject {
    
    // MARK: - Class Vars
    
    /// Expected size of the navigation bar, including its status bar
    static var size: CGSize {
        get {
            return CGSize(width: UIScreen.main.bounds.width, height: (UIApplication.safeAreaInsets.bottom > 0.0 ? 92.0 : 44.0) + (UIApplication.keyWindow?.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0))
        }
    }
    
    /// Initialized Boolean used to determine if the text field is active based on whether the TextField (UITextField) object has text
    var isSearching: Bool {
        get {
            return textField?.text?.isBlank == true ? false : true
        }
    }
    
    /// Returns this class' TextField (UITextField) object's text
    var text: String? {
        get {
            return textField?.text
        }
    }
    
    /// Returns the respective view controller's UINavigationBar
    var bar: UINavigationBar? {
        get {
            return viewController?.navigationController?.navigationBar
        }
    }
    
    // MARK: - TextField
    var textField: TextField!
    
    // MARK: - UITapGestureRecognizer
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    // MARK: - UILabel
    var titleLabel: UILabel!
    
    // MARK: - NavigationBarDelegate
    fileprivate var delegate: NavigationBarDelegate?
    
    // MARK: - NavigationTitleView
    fileprivate var navigationTitleView: NavigationTitleView!
    
    // MARK: - UIViewController
    fileprivate var viewController: UIViewController!
    
    /// Initialized closure called whenever the title label was tapped
    fileprivate var titleLabelClosure: (() -> Void)? = nil

    /// MARK: - Init
    /// - Parameter viewController: A UIViewController object
    /// - Parameter titleAttributedString: An optional NSAttributedString value
    /// - Parameter view: An optional UIView object for the navigation bar
    /// - Parameter delegate: An optional NavigationBarDelegate object
    /// - Parameter alignment: A NavigationBarTitleViewAlignment for the custom view object - defaults to .left
    /// - Parameter leftBarItems: An optional array of NavigationBarItem objects for the navigation item's left bar button items
    /// - Parameter rightBarItems: An optional array of NavigationBarItem objects for the navigation item's right bar button items
    /// - Parameter isTransparent: A Boolean value representing whether the navigation bar is translucent or not
    /// - Parameter textFieldLeftImage: An optional UIImage value representing the TextField object's leftView's image
    /// - Parameter textFieldDelegate: An optional UITextFieldDelegate for the text field
    /// - Parameter titleLabelClosure: An void closure called whenever the title button was tapped.
    init(viewController: UIViewController,
         titleAttributedString: NSAttributedString? = nil,
         view: UIView? = nil,
         delegate: NavigationBarDelegate? = nil,
         alignment: NavigationBarTitleViewAlignment = .left,
         leftBarItems: [NavigationBarItem]? = nil,
         rightBarItems: [NavigationBarItem]? = nil,
         isTransparent: Bool = false,
         textFieldLeftImage: UIImage? = UIImage(named: "Search"),
         titleLabelClosure: (() -> Void)? = nil) {
        super.init()
        
        // MARK: - NavigationBarDelegate
        self.delegate = delegate
        
        // MARK: - UIViewController
        self.viewController = viewController
        
        // Set the title label's closure
        self.titleLabelClosure = titleLabelClosure
        
        // Reset the navigation bar
        viewController.navigationItem.leftBarButtonItems?.removeAll()
        viewController.navigationItem.rightBarButtonItems?.removeAll()
        viewController.navigationItem.setHidesBackButton(true, animated: false)
        viewController.navigationItem.leftBarButtonItem = nil
        viewController.navigationItem.rightBarButtonItem = nil
        viewController.navigationItem.titleView = nil
        
        // Show the navigation bar
        viewController.navigationController?.setNavigationBarHidden(false, animated: true)
        viewController.navigationController?.navigationBar.alpha = 1.0
        
        // Calculate the status bar height
        let statusBarHeight = viewController.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0
        
        // MARK: - CAGradientLayer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: NavigationBar.size)
        gradientLayer.colors = isTransparent ? [UIColor.black.withAlphaComponent(0.80).cgColor, UIColor.black.withAlphaComponent(0.0).cgColor] : [UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.shouldRasterize = true
        // Get the gradient layer's image from above
        let gradientImage = imageFromLayer(gradientLayer).resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        
        // Configure the navigation bar
        viewController.navigationController?.navigationBar.shadowImage = imageWithColor(color: isTransparent ? UIColor.clear : UIColor.systemGray6)
        viewController.navigationController?.navigationBar.setBackgroundImage(gradientImage, for: .default)
        viewController.navigationController?.navigationBar.isTranslucent = isTransparent
        
        // Add a shadow to the navigation bar if it's transparent
        if isTransparent {
            viewController.navigationController?.navigationBar.layer.addShadow(offset: .zero, radius: 1.0)
        }
                
        // MARK: - NavigationTitleView
        self.navigationTitleView = NavigationTitleView(frame: CGRect(x: 0.0, y: NavigationBar.size.height - statusBarHeight, width: NavigationBar.size.width, height: NavigationBar.size.height - statusBarHeight))
        self.navigationTitleView.backgroundColor = .clear
        self.navigationTitleView.clipsToBounds = false
        self.navigationTitleView.translatesAutoresizingMaskIntoConstraints = false
        self.navigationTitleView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.navigationTitleView.leadingAnchor.constraint(equalTo: navigationTitleView.leadingAnchor).isActive = true
        self.navigationTitleView.topAnchor.constraint(equalTo: navigationTitleView.topAnchor).isActive = true
        self.navigationTitleView.trailingAnchor.constraint(equalTo: navigationTitleView.trailingAnchor).isActive = true
        self.navigationTitleView.bottomAnchor.constraint(equalTo: navigationTitleView.bottomAnchor).isActive = true
        self.navigationTitleView.heightAnchor.constraint(equalTo: self.navigationTitleView.heightAnchor, constant: NavigationBarItem.height).isActive = true
        viewController.navigationItem.titleView = self.navigationTitleView
        
        // MARK: - UIBarButtonItem
        let leftBarButtonItems = leftBarItems?.map({ (item: NavigationBarItem) -> [UIBarButtonItem] in
            // MARK: - UIBarButtonItem
            let itemBarButtonItem = UIBarButtonItem(customView: item)
            itemBarButtonItem.tintColor = item.tintColor
            // Create another UIBarButtonItem to add spacing between items
            let spacingBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            spacingBarButtonItem.width = 3
            return [itemBarButtonItem, spacingBarButtonItem]
        }).reversed().flatMap({$0})
        viewController.navigationItem.setLeftBarButtonItems(leftBarButtonItems, animated: false)
        
        // MARK: - UIBarButtonItem
        let rightBarButtonItems = rightBarItems?.map({ (item: NavigationBarItem) -> [UIBarButtonItem] in
            // MARK: - UIBarButtonItem
            let itemBarButtonItem = UIBarButtonItem(customView: item)
            itemBarButtonItem.tintColor = item.tintColor
            // Create another UIBarButtonItem to add spacing between items
            let spacingBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            spacingBarButtonItem.width = 3
            return [itemBarButtonItem, spacingBarButtonItem]
        }).reversed().flatMap({$0})
        viewController.navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: false)
        
        if let view = view {
            // Add the view to the navigationTitleView
            self.navigationTitleView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            // MARK: - NSLayoutConstraint
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: view as Any, attribute: .leading, relatedBy: alignment == .right ? .lessThanOrEqual : .equal, toItem: self.navigationTitleView as Any, attribute: .leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: view as Any, attribute: .top, relatedBy: .equal, toItem: self.navigationTitleView as Any, attribute: .top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: view as Any, attribute: .trailing, relatedBy: alignment == .left ? .lessThanOrEqual : .equal, toItem: self.navigationTitleView as Any, attribute: .trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: view as Any, attribute: .bottom, relatedBy: .equal, toItem: self.navigationTitleView as Any, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            ])
            
        } else if delegate != nil {
            // MARK: - TextField
            // Setup the text field as the title view
            textField = TextField(frame: CGRect(origin: .zero, size: NavigationBar.size))
            textField!.backgroundColor = isTransparent ? UIColor.clear : UIColor.systemGray6
            textField!.setLeftViewIcon(image: textFieldLeftImage, color: isTransparent ? UIColor.white : UIColor.lightGray)
            textField!.textColor = isTransparent ? UIColor.white : UIColor.black
            textField!.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            textField!.layer.cornerRadius = 16.0
            textField!.clipsToBounds = true
            textField!.isUserInteractionEnabled = true
            textField!.attributedPlaceholder = titleAttributedString
            textField!.returnKeyType = .done
            textField!.delegate = self
            navigationTitleView.addSubview(textField!)
            textField!.translatesAutoresizingMaskIntoConstraints = false
            textField!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            // MARK: - NSLayoutConstraint
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: textField as Any, attribute: .leading, relatedBy: .equal, toItem: self.navigationTitleView as Any, attribute: .leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: textField as Any, attribute: .top, relatedBy: .equal, toItem: self.navigationTitleView as Any, attribute: .top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: textField as Any, attribute: .trailing, relatedBy: .equal, toItem: self.navigationTitleView as Any, attribute: .trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: textField as Any, attribute: .bottom, relatedBy: .equal, toItem: self.navigationTitleView as Any, attribute: .bottom, multiplier: 1.0, constant: -8.0)
            ])
            
        } else {
            // MARK: - UILabel
            titleLabel = UILabel(frame: CGRect(origin: .zero, size: NavigationBar.size))
            titleLabel.backgroundColor = .clear
            titleLabel.backgroundColor = .clear
            titleLabel.textAlignment = alignment == .left ? .left : alignment == .right ? .right : .center
            titleLabel.lineBreakMode = .byTruncatingMiddle
            titleLabel.numberOfLines = 2
            titleLabel.attributedText = titleAttributedString
            titleLabel.clipsToBounds = true
            navigationTitleView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            // MARK: - NSLayoutConstraint
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: titleLabel as Any,
                                   attribute: .leading,
                                   relatedBy: .equal,
                                   toItem: self.navigationTitleView as Any,
                                   attribute: .leading,
                                   multiplier: 1.0,
                                   constant: 0.0),
                NSLayoutConstraint(item: titleLabel as Any,
                                   attribute: .top,
                                   relatedBy: .equal,
                                   toItem: self.navigationTitleView as Any,
                                   attribute: .top,
                                   multiplier: 1.0,
                                   constant: 0.0),
                NSLayoutConstraint(item: titleLabel as Any,
                                   attribute: .trailing,
                                   relatedBy: alignment == .left || alignment == .right ? .lessThanOrEqual : .equal,
                                   toItem: self.navigationTitleView as Any,
                                   attribute: .trailing,
                                   multiplier: 1.0,
                                   constant: 0.0),
                NSLayoutConstraint(item: titleLabel as Any,
                                   attribute: .bottom,
                                   relatedBy: .equal,
                                   toItem: self.navigationTitleView as Any,
                                   attribute: .bottom,
                                   multiplier: 1.0,
                                   constant: 0.0)
            ])
            
            // MARK: - UITapGestureRecognizer
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(activateTitleLabelClosure(_:)))
            tapGestureRecognizer.numberOfTapsRequired = 1
            titleLabel.isUserInteractionEnabled = true
            titleLabel.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    /// Called when the title label was tapped
    /// - Parameter sender: Any object that calls this method
    @objc fileprivate func activateTitleLabelClosure(_ sender: Any) {
        // Call the title label's closure
        self.titleLabelClosure?()
    }
    
    /// Called when the text field changes its text
    /// - Parameter textField: A UITextField object that calls this method
    @objc fileprivate func textFieldDidChange(_ textField: UITextField) {
        self.textFieldDidEndEditing(textField)
    }
    
    /// Generates a background color for the navigation bar
    /// - Parameter isTransparent: A Boolean value indicating whether the navigation bar is transparent or not
    /// - Parameter viewController: A UIViewController object representing the height of the navigation bar
    fileprivate func backgroundImage(isTransparent: Bool, viewController: UIViewController) -> UIImage {
        // MARK: - CAGradientLayer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: viewController.navigationController?.navigationBar.frame.width ?? UIScreen.main.bounds.width, height: (viewController.navigationController?.navigationBar.frame.height ?? 0.0) + (viewController.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0))
        gradientLayer.colors = isTransparent ? [UIColor.black.withAlphaComponent(0.90).cgColor, UIColor.black.withAlphaComponent(0.50).cgColor, UIColor.black.withAlphaComponent(0.0).cgColor] : [UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.shouldRasterize = true
        
        // MARK: - UIGraphicsBeginImageContext
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
    }
    
    /// Returns an image snapshot of a CALayer object
    /// - Parameter layer: A CALayer object to draw the image with
    fileprivate func imageFromLayer(_ layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
    
    /// Generates a UIImage for the navigation bar's shadow image
    /// - Parameter color: A UIColor value specifying the shadow image's color
    fileprivate func imageWithColor(color: UIColor) -> UIImage {
        let pixelScale = UIScreen.main.scale
        let pixelSize = 1.0/pixelScale
        let fillSize = CGSize(width: pixelSize, height: pixelSize)
        let fillRect = CGRect(origin: .zero, size: fillSize)
        UIGraphicsBeginImageContextWithOptions(fillRect.size, false, pixelScale)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext!.setFillColor(color.cgColor)
        graphicsContext!.fill(fillRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /// Manages the text field's first responder status
    /// - Parameter isResigning: A Boolean value indicating whether the text field is resigning its first responder status or becoming a frist responder status
    open func manageFirstResponder(_ isResigning: Bool) {
        switch isResigning {
        case true:
            // MARK: - TextField
            textField?.resignFirstResponder()
        case false:
            // MARK: - TextField
            textField?.becomeFirstResponder()
        }
    }
    
    /// Set the TextField's text, color, and font
    /// - Parameter text: A String value used to set the text field's text
    /// /// - Parameter color: A UIColor value
    /// - Parameter font: A UIFont value
    open func setTextFieldText(_ text: String?, color: UIColor, font: UIFont) {
        // Unwrap the String value
        guard let text = text, !text.isBlank else {
            print("\(#file)/\(#line) - Can't set text that's nil or blank")
            return
        }
        
        // Update the text field's text, color, and font
        textField.text = text
        textField.textColor = color
        textField.font = font
    }
    
    // Update the TextField's ```attributedPlaceholder``` or ActiveButton's title
    /// - Parameter titleAttributedString: A NSAttributedString object
    open func updateTitle(_ titleAttributedString: NSAttributedString) {
        // MARK: - TextField
        if let textField = textField {
            textField.attributedPlaceholder = titleAttributedString
        } else if let titleLabel = titleLabel {
            titleLabel.attributedText = titleAttributedString
        }
    }
}



// MARK: - UITextFieldDelegate
extension NavigationBar: UITextFieldDelegate {
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // MARK: - NavigationBarDelegate
        delegate?.navigationBarTextFieldDidClear?(textField)
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // MARK: - NavigationBarDelegate
        delegate?.navigationBarTextFieldDidReturn?(textField)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        // MARK: - NavigationBar
        delegate?.navigationBarTextFieldUpdatedEdits?(textField)
    }
}


