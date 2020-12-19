//
//  TextField.swift
//  NavigationTransitionController
//
//  Created by Joshua Choi on 7/16/20.
//  Copyright © 2020 Joshua Choi. All rights reserved.
//

import UIKit



/**
 Abstract: UITextField subclass
 */
public class TextField: UITextField {
    
    // MARK:- Class Vars
    
    /// Closure called when the right view button is tapped
    var rightViewMethod: (() -> Void)? = nil
    
    /// Initialized UIImage value used to set the rightViewButton
    var rightViewIcon: UIImage? {
        didSet {
            // Set the right view button's image
            self.rightViewButton.setImage(rightViewIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    // MARK: - ActiveButton
    var rightViewButton: ActiveButton!
    
    // - Tag
    public override var backgroundColor: UIColor? {
        didSet {
            // Setup the clear button
            setupClearButton()
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    fileprivate func setup() {
        frame = bounds
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        borderStyle = .none
        autocorrectionType = .no
        clearButtonMode = .whileEditing
        tintColor = UIColor.blue
        textColor = UIColor.black
        
        // Attach the selector method
        addTarget(self, action: #selector(TextField.textFieldChanged(_:)), for: .editingChanged)
        
        // Setup the clear button
        setupClearButton()
    }
    
    /// Called when the right view button was tapped
    /// - Parameter sender: Any object that called this method
    @objc fileprivate func rightViewCTA(_ sender: Any) {
        self.rightViewMethod?()
    }

    /// Private selector method to hide/show the right view based on the text
    /// - Parameter textField: A UITextField object that calls this method (aka this class)
    @objc fileprivate func textFieldChanged(_ textField: UITextField) {
        // Hide/show the right view button
        rightViewButton.alpha = textField.text?.isBlank == true ? 1.0 : 0.0
    }
    
    /// Setup the clear button
    fileprivate func setupClearButton() {
        // MARK: - UIButton
        if let clearButton = value(forKey: "clearButton") as? UIButton {
            clearButton.setImage(UIImage(named: "Exit")!.withRenderingMode(.alwaysTemplate), for: .normal)
            clearButton.contentEdgeInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
            clearButton.imageEdgeInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
            clearButton.backgroundColor = UIColor.lightGray
            clearButton.tintColor = backgroundColor == .clear || backgroundColor?.withAlphaComponent(0.0) == backgroundColor ? UIColor.white : backgroundColor ?? UIColor.white
            clearButton.layer.cornerRadius = clearButton.frame.size.height/2
            clearButton.clipsToBounds = true
        }
    }
    
    // - Tag
    public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var clearButtonFrame = CGRect(x: 0, y: 0, width: 20.0, height: 20.0)            // Set the frame's width/height to be 20
        clearButtonFrame.origin.x = bounds.width - clearButtonFrame.width - 8.0         // Set the x-origin to have 8 point padding from the right
        clearButtonFrame.origin.y = (bounds.height - clearButtonFrame.height)/2.0       // Set the y-origin to be in the center
        return clearButtonFrame
    }
    
    // - Tag
    public override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: bounds.height == 0.0 ? 34.00 : bounds.height, height: bounds.height == 0.0 ? 34.00 : bounds.height)
    }
}




// MARK: - UITextField
extension TextField {
    // Set the left view's UIImage value
    /// - Parameter image: A UIImage value
    /// - Parameter color: An optional UIColor value representing the UIImage's tint color. Defaults to the UITextField's attributedPlaceHolder's UITextColor.
    func setLeftViewIcon(image: UIImage?, color: UIColor? = nil) {
        // Only set the UITextField's leftView if there's a UIImage value
        guard let image = image else {
            return
        }
        
        // Get the UIColor
        let color = color ?? attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? UIColor.lightGray
        
        // MARK: - UIImageView
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18.0, height: 18.0))
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = color
        imageView.image = image.withRenderingMode(.alwaysTemplate)
        
        // MARK: - PassiveView
        let iconView = UIView(frame: CGRect(x: 0, y: 0, width: 34.0, height: 34.0))
        iconView.backgroundColor = .clear
        iconView.tintColor = color
        iconView.clipsToBounds = true
        iconView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.widthAnchor.constraint(equalToConstant: imageView.frame.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageView.frame.height).isActive = true
        imageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
        
        // Set the left view
        leftView = iconView
        leftViewMode = .always
        leftView?.isUserInteractionEnabled = false
    }
}
