//
//  MenuCell.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 25/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class MenuView : UIControl
{
    @IBInspectable var label : String = "" {
        didSet { nameLabel.text = label }
    }
    @IBInspectable var image : UIImage = UIImage() {
        didSet { menuImage.image = image }
    }
    @IBInspectable var opacity : CGFloat = 1 {
        didSet { menuImage.alpha = opacity }
    }
    var menu : UIView!
    
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    @IBAction func selected() {
        UIView.animate(withDuration: 0.25) {
            self.menu.transform = .init(scaleX: 0.95, y: 0.95)
        }
    }
    
    @IBAction func unselected() {
        UIView.animate(withDuration: 0.25) {
            self.menu.transform = .identity
        }
    }
    
    func setup() {
        loadNib()
        menu.layer.cornerRadius = 16
        menu.layer.borderWidth = 0.5
        menu.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = true
        addTarget(self, action: #selector(unselected), for: UIControl.Event.touchUpInside)
        addTarget(self, action: #selector(unselected), for: UIControl.Event.touchUpOutside)
        addTarget(self, action: #selector(unselected), for: UIControl.Event.touchCancel)
        addTarget(self, action: #selector(selected), for: UIControl.Event.touchDown)
    }
    
    
    
    func loadNib() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        sendSubviewToBack(view)
        menu = view
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "MenuCell", bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil).first as? UIView
    }
    
    
    
    /*override func awakeFromNib() {
     super.awakeFromNib()
     loadNib()
     }
    
    override func prepareForInterfaceBuilder() {
     super.prepareForInterfaceBuilder()
     loadNib()
     menu.prepareForInterfaceBuilder()
     }*/
}
