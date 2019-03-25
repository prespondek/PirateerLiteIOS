//
//  MarketCellView.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 24/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class MarketCellView: UITableViewCell {
    @IBOutlet weak var boatImage: UIImageView!
    @IBOutlet weak var boatName: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var moneyIcon: UIImageView!
    
    var boatPart : User.BoatPart!
    
    func setup ( part: User.BoatPart ) {
        boatPart = part
        update()
    }
    
    func update () {
        moneyIcon.image = UIImage(named: "gold_piece")
        let boatInfo = BoatModel.boatValues[boatPart.boat]!
        var cost = 0
        if boatPart.item.rawValue < 4 {
            let partInfo = BoatModel.boatParts[boatPart.item.rawValue]
            boatImage.image = UIImage(named: partInfo[1])
            boatName.text = boatInfo[BoatModel.BoatIndex.title.rawValue] as! String + " " + partInfo[0]
            cost = (boatInfo[BoatModel.BoatIndex.part_cost.rawValue] as! Array<Int>)[boatPart.item.rawValue]
            moneyLabel.text = String(cost)
        } else {
            boatImage.image = UIImage(named: boatPart.boat + "_01")
            boatName.text = boatInfo[BoatModel.BoatIndex.title.rawValue] as? String
            cost = boatInfo[BoatModel.BoatIndex.boat_cost.rawValue] as! Int
            moneyLabel.text = String(cost)
        }
        if ( cost <= User.sharedInstance.gold) {
            self.isUserInteractionEnabled = true
            backgroundColor = UIColor.white
            boatImage.alpha = 1
            boatName.alpha = 1
        } else {
            self.isUserInteractionEnabled = false
            backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            boatImage.alpha = 0.5
            boatName.alpha = 0.5
        }
    }
}
