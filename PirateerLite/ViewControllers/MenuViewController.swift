//
//  MenuController.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 7/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var statisticsButton:    MenuView!
    @IBOutlet weak var shipyardButton:      MenuView!
    @IBOutlet weak var bankButton:          MenuView!
    @IBOutlet weak var marketButton:        MenuView!
    @IBOutlet weak var statsPanel:          UIView!
    @IBOutlet weak var xpLabel:             UILabel!
    @IBOutlet weak var nextXPLabel:         UILabel!
    @IBOutlet weak var silverLabel:         UILabel!
    @IBOutlet weak var goldLabel:           UILabel!
    @IBOutlet weak var levelImage:          UIImageView!
    @IBOutlet weak var levelLabel:          UILabel!
    @IBOutlet weak var exchangeLabel:       StrokedLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statsPanel.layer.shadowColor = UIColor.black.cgColor
        self.statsPanel.layer.shadowOpacity = 0.3
        self.statsPanel.layer.shadowOffset = CGSize(width: 0, height: -6)
        self.statsPanel.layer.shadowRadius = 4
        self.statsPanel.layer.masksToBounds = false
        User.sharedInstance.addObserver(self)
        goldUpdated(oldValue: 0, newValue: User.sharedInstance.gold)
        silverUpdated(oldValue: 0, newValue: User.sharedInstance.silver)
        xpUpdated(oldValue: 0, newValue: User.sharedInstance.xp)
        exchangeLabel.text = String(User.exchangeRate)
        goldUpdated(oldValue:0,newValue:User.sharedInstance.gold)
    }
    
    @IBAction func marketButtonPressed(_ sender: Any) {
        performSegue( withIdentifier: "MarketSegue", sender: nil )
    }
    @IBAction func shipyardButtonPressed(_ sender: Any) {
        performSegue( withIdentifier: "ShipyardSegue", sender: nil )
    }
    
    @IBAction func bankButtonPressed(_ sender: Any) {
        User.sharedInstance.addMoney(gold: -1, silver: User.exchangeRate)
        User.sharedInstance.save()
    }
    
    @IBAction func statsButtonPressed(_ sender: Any) {
        performSegue( withIdentifier: "StatsSegue", sender: nil )
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        //tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func unwindToMenu(segue:UIStoryboardSegue) {
        performSegue(withIdentifier: "unwindSegueToMap", sender: self)
    }
}

extension MenuViewController : UserObserver
{
    func goldUpdated(oldValue: Int, newValue: Int) {
        goldLabel.text = String(newValue)
        if newValue > 0 {
            bankButton.isUserInteractionEnabled = true
        } else {
            bankButton.isUserInteractionEnabled = false
        }
    }
    
    func silverUpdated(oldValue: Int, newValue: Int) {
        silverLabel.text = String(newValue)
    }
    
    func xpUpdated(oldValue: Int, newValue: Int) {
        let user = User.sharedInstance
        xpLabel.text = String(newValue)
        nextXPLabel.text = String(user.xpForLevel(user.level + 1) - user.xp )
        let level_image = User.rankValues[User.rankKeys[user.level]]![0] as! String
        levelImage.image = UIImage(named: level_image)
        levelLabel.text = User.rankValues[User.rankKeys[user.level]]![1] as! String
    }
}
