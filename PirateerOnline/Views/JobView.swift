//
//  JobView.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 17/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class JobView : UIView
{

    @IBOutlet weak var bonusLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var jobStack: UIStackView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var currencyIcon: UIImageView!
    @IBOutlet weak var jobImage: UIImageView!
    @IBOutlet weak var labelBG: UIView!
    
    var job : JobModel? {
        didSet {
            if let job = job as? JobModel {
                let element = JobController.jobData.first(where: { $0[0] == job.type })
                jobImage.image = UIImage(named: element![1])
                destinationLabel.text = job.destination.name
                costLabel.text = String(Int(round(job.value)))
                if job.isGold {
                    currencyIcon.image = UIImage(named: "gold_piece")
                } else {
                    currencyIcon.image = UIImage(named: "silver_piece")
                }
                jobStack.isHidden = false
                emptyLabel.isHidden = true
                labelBG.backgroundColor = job.destination.color
            } else {
                jobStack.isHidden = true
                emptyLabel.isHidden = false
                bonusLabel.isHidden = true
                backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            }
            bonusLabel.attributedText = NSAttributedString(string: "+25%", attributes:
                [ NSAttributedString.Key.strokeWidth : -4,
                  NSAttributedString.Key.strokeColor : UIColor.black,
                  NSAttributedString.Key.foregroundColor : UIColor.yellow,
                  NSAttributedString.Key.font : UIFont(name: "AmericanTypewriter-Bold", size: 32)!])
            layer.cornerRadius = 16
            layer.borderWidth = 0.5
        }
    }
    
    func bonus(_ enabled: Bool) {
        if enabled {
            bonusLabel.isHidden = false
            backgroundColor = UIColor.green
        } else {
            backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            bonusLabel.isHidden = true
        }
    }
    
    func highlighted () {
        UIView.animate(withDuration: 0.25) {
            self.transform = .init(scaleX: 0.95, y: 0.95)
        }
        
    }
    
    func unhighlighted () {
        UIView.animate(withDuration: 0.25) {
            self.transform = .identity
        }
    }
    
    
    func setParent(view: UIView) {
        let margins = view.layoutMarginsGuide
        widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.2)
    }


    
}
