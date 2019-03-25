//
//  UIExtensions.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 12/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class FilledButton : UIButton {
    @IBInspectable var disabledColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0) {
        didSet { updateColor(color: disabledColor, state: .disabled) }
    }
    @IBInspectable var highlightedColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0) {
        didSet { updateColor(color: highlightedColor, state: .highlighted) }
    }
    @IBInspectable var selectedColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0) {
        didSet { updateColor(color: selectedColor, state: .selected) }
    }
    @IBInspectable var strokeColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0) {
        didSet { updateStroke(color: strokeColor, width: strokeWidth) }
    }
    @IBInspectable var roundedCornerRadius : CGFloat = 0 {
        didSet { updateCorners(radius: roundedCornerRadius) }
    }
    @IBInspectable var strokeWidth : CGFloat = 0 {
        didSet { updateStroke(color: strokeColor, width: strokeWidth) }
    }
    
    private func image(withColor color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), true, 0.0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        return image
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func updateColor(color: UIColor, state: UIControl.State) {
        let image = self.image(withColor: color)
        setBackgroundImage(image, for: state)
        clipsToBounds = true
    }
    func updateCorners ( radius: CGFloat ) {
        layer.cornerRadius = radius
    }
    func updateStroke( color: UIColor, width: CGFloat ) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    func setup () {
        setBackgroundColor(disabledColor, for: .disabled)
        setBackgroundColor(highlightedColor, for: .highlighted)
        setBackgroundColor(selectedColor, for: .selected)
        updateCorners(radius: roundedCornerRadius)
        updateStroke(color: strokeColor, width: strokeWidth)
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(image(withColor: color), for: state)
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

extension UIColor {
    convenience init(hex: String) {
        var colors = [CGFloat]()
        //let lower = hex.lowercased()
        for i in stride(from: 0, to: min(hex.count,6), by: 2) {
            let substr = String(hex[i..<i+2])
            if let value = UInt8(substr, radix: 16) {
                colors.append(CGFloat(value)/255.0)
            }
        }
        self.init(red: colors[2], green: colors[1], blue: colors[0], alpha: 1.0)
    }
}

@IBDesignable
class StrokedLabel: UILabel {
    override var text: String? {
        didSet {
            update()
        }
    }
    @IBInspectable var strokeSize: Double = 1 {
        didSet {
            update()
        }
    }
    @IBInspectable var strokeColor: UIColor = UIColor.black {
        didSet {
            update()
        }
    }
    
    func update() {
        if text == nil { return }
        let strokeTextAttributes : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strokeColor : strokeColor,
            NSAttributedString.Key.foregroundColor : textColor,
            NSAttributedString.Key.strokeWidth : -strokeSize,
            NSAttributedString.Key.font : font
            ] as [NSAttributedString.Key  : Any]
        
        let customizedText = NSMutableAttributedString(string: text!,
                                                       attributes: strokeTextAttributes)
        attributedText = customizedText
    }
}
