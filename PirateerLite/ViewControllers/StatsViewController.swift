//
//  StatsViewController.swift
//  ClearForActionLite
//
//  Created by Peter Respondek on 18/3/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class StatsViewController: UIViewController, UserObserver
{
    @IBOutlet weak var leveLabel:               UILabel!
    @IBOutlet weak var levelImage:              UIImageView!
    @IBOutlet weak var nextXpLabel:             UILabel!
    @IBOutlet weak var totalXpLabel:            UILabel!
    @IBOutlet weak var goldLabel:               UILabel!
    @IBOutlet weak var silverLabel:             UILabel!
    @IBOutlet weak var fleetSize:               UILabel!
    @IBOutlet weak var boatsSold:               UILabel!
    @IBOutlet weak var netWorth:                UILabel!
    @IBOutlet weak var totalVoyages:            UILabel!
    @IBOutlet weak var topEarningImage:         UIImageView!
    @IBOutlet weak var topEarningName:          UILabel!
    @IBOutlet weak var topEarningValue:         UILabel!
    @IBOutlet weak var spmName:                 UILabel!
    @IBOutlet weak var spmImage:                UIImageView!
    @IBOutlet weak var spmValue:                UILabel!
    @IBOutlet weak var mostVayagesName:         UILabel!
    @IBOutlet weak var distanceSailed:          UILabel!
    @IBOutlet weak var mostVoyagesImage:        UIImageView!
    @IBOutlet weak var mostVoyagesValue:        UILabel!
    @IBOutlet weak var mostMileageName:         UILabel!
    @IBOutlet weak var mostMileageValue:        UILabel!
    @IBOutlet weak var mostMileageImage:        UIImageView!
    @IBOutlet weak var mostGoodsSoldSilver:     UILabel!
    @IBOutlet weak var mostGoodsSoldLabel:      UILabel!
    @IBOutlet weak var mostFrequentedValue:     UILabel!
    @IBOutlet weak var mostFrequentedName:      UILabel!
    @IBOutlet weak var mostGoodsBoughtLabel:    UILabel!
    @IBOutlet weak var mostGoodsBoughtSilver:   UILabel!
    @IBOutlet weak var totalSPM:                UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }
    
    func statsUpdated () {
        update()
    }
    
    func update() {
        let user = User.sharedInstance
        user.addObserver(self)
        var rankInfo = User.rankValues[User.rankKeys[user.level]]!
        leveLabel.text =  rankInfo[1] as? String
        levelImage.image = UIImage(named: rankInfo[0] as! String)
        nextXpLabel.text =  String(user.xpForLevel(user.level + 1) - user.xp)
        totalXpLabel.text = String(user.xp)
        goldLabel.text =    String(user.gold)
        silverLabel.text =  String(user.silver)
        fleetSize.text =    String(user.boats.count)
        boatsSold.text =    String(user.stats.boatsSold)
        totalSPM.text =     String(format: "%.2f", Double(user.silver) / (Date().timeIntervalSince(user.startDate) / 60.0))
        totalVoyages.text = String(user.stats.voyages)
        distanceSailed.text = String(format: "%.0f", user.stats.distance)
        var worth = user.silver
        for boat in user.boats {
            worth += boat.value
        }
        netWorth.text = String(worth)
        var mostBought : TownModel? = nil
        var mostSold : TownModel? = nil
        var mostFrequented : TownModel? = nil
        for town in Map.sharedInstance.towns {
            if town.level == 0 { continue }
            if mostBought == nil || town.stats.startSilver > mostBought!.stats.startSilver {
                mostBought = town
            }
            if mostSold == nil || town.stats.endSilver > mostSold!.stats.endSilver {
                mostSold = town
            }
            if mostFrequented == nil || town.stats.totalVisits > mostFrequented!.stats.totalVisits {
                mostFrequented = town
            }
        }
        if mostBought != nil {
            mostGoodsBoughtLabel.text = mostBought?.name
            mostGoodsBoughtSilver.text = String(mostBought!.stats.startSilver)
        }
        if mostSold != nil {
            mostGoodsSoldLabel.text = mostSold?.name
            mostGoodsSoldSilver.text = String(mostSold!.stats.endSilver)
        }
        if mostFrequented != nil {
            mostFrequentedName.text = mostSold?.name
            mostFrequentedValue.text = String(mostSold!.stats.totalVisits)
        }
        
        if let maxDistance = User.sharedInstance.stats.boatStats["maxDistance"] {
            mostMileageName.text = maxDistance.name
            mostMileageValue.text = String(format: "%.0f", maxDistance.stats.totalDistance)
            mostMileageImage.image = UIImage(named: maxDistance.type + "_01")
        }
        
        if let topEarning = User.sharedInstance.stats.boatStats["maxProfit"] {
            topEarningName.text = topEarning.name
            topEarningValue.text = String(topEarning.stats.totalSilver)
            topEarningImage.image = UIImage(named: topEarning.type + "_01")
        }
        
        if let mostVoyages = User.sharedInstance.stats.boatStats["maxVoyages"] {
            mostVayagesName.text = mostVoyages.name
            mostVoyagesValue.text = String(mostVoyages.stats.totalVoyages)
            mostVoyagesImage.image = UIImage(named: mostVoyages.type + "_01")
        }
        
        if let spm = User.sharedInstance.stats.boatStats["SPM"] {
            spmName.text = spm.name
            spmValue.text = String(format: "%.0f", max(0.0, spm.stats.SPM))
            spmImage.image = UIImage(named: spm.type + "_01")
        }
    }
}
