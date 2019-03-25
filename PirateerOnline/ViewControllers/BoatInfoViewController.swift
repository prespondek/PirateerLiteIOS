//
//  BoatInfoViewController.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 24/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class BoatInfoViewController: UIViewController
{
    @IBOutlet weak var buildButton: FilledButton!
    @IBOutlet weak var boatInfo: UITextView!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var cargoSizeLabel: UILabel!
    @IBOutlet weak var boatNameLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var hullLabel: UILabel!
    @IBOutlet weak var cannonsLabel: UILabel!
    @IBOutlet weak var partsLabel: UILabel!
    @IBOutlet weak var sailsLabel: UILabel!
    @IBOutlet weak var boatImage: UIImageView!
    @IBOutlet weak var harbourSizeLabel: UIImageView!
    
    var boatType : String!
    var parts = Array<User.BoatPart>()
    
    @IBAction func buildButtonPressed(_ sender: Any) {
        if User.sharedInstance.numBoats < User.sharedInstance.boatSlots {
            performSegue(withIdentifier: "unwindSegueToMap", sender: self)
        } else {
            let alert = UIAlertController(title: "Purchase Boat", message: "You do not have enough boat slots. Purchase more space from the boat menu." , preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
            //self.present(alert, animated: true)
            AlertQueue.shared.pushAlert(alert)
        }

    }
    func boatValue (_ index: BoatModel.BoatIndex) -> Any {
        return BoatModel.boatData(type: boatType, with: index)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rangeLabel.text =       String(boatValue(.distance) as! Double) + " miles"
        speedLabel.text =       String(boatValue(.speed) as! Double) + " knots"
        boatImage.image =       UIImage(named: boatValue(.image) as! String)
        boatNameLabel.text =    boatValue(.title) as? String
        cargoSizeLabel.text =   String(boatValue(.hold_size) as! Int)
        boatInfo.text =         boatValue(.description) as? String
        switch TownModel.HarbourSize(rawValue: boatValue(.harbourType) as! String)! {
        case .small:
            harbourSizeLabel.image = UIImage(named: "town_c1_unselected")
        case .medium:
            harbourSizeLabel.image = UIImage(named: "town_c2_unselected")
        default:
            harbourSizeLabel.image = UIImage(named: "town_c3_unselected")
        }
        
        let arr = [hullLabel,partsLabel,sailsLabel,cannonsLabel]
        var parts = boatValue(.part_amount) as! Array<Int>
        var canBuild = true
        for i in 0..<parts.count {
            let currPart = User.BoatPart(boat:boatType,item: User.MarketItem(rawValue: i)!)
            let label = arr[i]
            let tparts = (User.sharedInstance.parts.filter {$0 == currPart})
            let numParts = tparts.count
            let targetParts = parts[i]
            label?.text = String(numParts) + "/" + String(targetParts)
            if numParts >= targetParts {
                for i in 0..<targetParts {
                    self.parts.append(tparts[i])
                }
                label?.textColor = UIColor.green
            } else {
                label?.textColor = UIColor.red
                canBuild = false
            }
        }
        if canBuild != true {
            buildButton.isEnabled = false
        }
            
        
    }
    
}
