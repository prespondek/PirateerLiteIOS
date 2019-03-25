//
//  XibView.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 19/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class XibView : UIView {
    var contentView:UIView?
    @IBInspectable var nibName : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
    }
    
    func loadViewFromNib() -> UIView? {
        guard let nibName = nibName else { return nil }
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil).first as? UIView
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }
}
