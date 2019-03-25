//
//  XibView.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 11/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class WalletView : UIView, UserObserver {
    func goldUpdated(oldValue: Int, newValue: Int) {
        goldLabel.text = String(User.sharedInstance.gold)
    }
    
    func silverUpdated(oldValue: Int, newValue: Int) {
        silverLabel.text = String(User.sharedInstance.silver)
    }
    
    func xpUpdated(oldValue: Int, newValue: Int) {
        let user = User.sharedInstance
        xpLabel.text = String(user.xpForLevel(user.level) - user.xp )
        let level_image = User.rankValues[User.rankKeys[user.level]]![0] as! String
        xpImage.image = UIImage(named: level_image)
    }
    
    
    @IBOutlet weak var silverLabel : UITextField!
    @IBOutlet weak var goldLabel : UITextField!
    var contentView:UIView?
    @IBOutlet weak var xpLabel: UITextField!
    @IBOutlet weak var xpImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        User.sharedInstance.addObserver(self)
        goldUpdated(oldValue: 0, newValue: 0)
        silverUpdated(oldValue: 0, newValue: 0)
        xpUpdated(oldValue: 0, newValue: 0)
    }
    
    func setup() {
        loadNib()
    }
    
    deinit {
        //User.sharedInstance.removeObserver(self)
    }
    
    func loadNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "Wallet", bundle: bundle)
        let view = nib.instantiate(
            withOwner: self,
            options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
    }
}

