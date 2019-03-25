//
//  ShipyardCellView.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 25/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class ShipyardCellView: UITableViewCell {
    
    @IBOutlet weak var rankIcon: UIImageView!
    @IBOutlet weak var boatImage: UIImageView!
    @IBOutlet weak var boatType: UILabel!
    @IBOutlet weak var buildIcon: UIImageView!
    
    var boatName : String!
    
    func setBoatData (name: String, data: Array<Any>) {
        let rank = data[15] as! String
        boatName = name
        rankIcon.image = UIImage(named: User.rankValues[rank]![0] as! String)!
        boatImage.image = UIImage(named: name + "_01")
        boatType.text = data[13] as? String
        if User.sharedInstance.level < User.rankKeys.firstIndex(of: rank)! {
            self.isUserInteractionEnabled = false
            boatType.isEnabled = false
            backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            boatImage.alpha = 0.5
            rankIcon.alpha = 0.5
            buildIcon.isHidden = true
        } else {
            self.isUserInteractionEnabled = true
            boatType.isEnabled = true
            backgroundColor = UIColor.white
            boatImage.alpha = 1
            rankIcon.alpha = 1
            buildIcon.isHidden = true
        }
        if User.sharedInstance.canBuildBoat(type: name) {
            buildIcon.isHidden = false
        } else {
            buildIcon.isHidden = true
        }
    }
}

