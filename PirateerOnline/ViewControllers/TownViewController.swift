//
//  TownViewControler.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 11/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class TownViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    weak var townController: TownController!
    
    @IBOutlet weak var costLabel:       UILabel!
    @IBOutlet weak var sizeLabel:       UILabel!
    @IBOutlet weak var typeLabel:       UILabel!
    @IBOutlet weak var classLabel:      UILabel!
    @IBOutlet weak var townNameLabel:   UILabel!
    @IBOutlet weak var upgradeButton:   FilledButton!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var townPortrait:    UIImageView!
    @IBOutlet weak var boatList:        UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if townController.model.level > 0 {
            let button = UIBarButtonItem(title: "Jobs", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TownViewController.jobsButtonPressed(_:)))
            navigationItem.rightBarButtonItem = button
        }
        townNameLabel.text = townController.model.name
        descriptionText.text = townController.model.description
        townPortrait.image = UIImage(named: townController!.model.type.rawValue)
        townPortrait.layer.cornerRadius = 24
        townPortrait.layer.masksToBounds = true
        classLabel.text = townController.model.harbour.rawValue.capitalizingFirstLetter()
        typeLabel.text = townController.model.type.rawValue.capitalizingFirstLetter()
        boatList.delegate = self
        boatList.dataSource = self
        boatList.register(UINib(nibName: "BoatCell", bundle: nil), forCellReuseIdentifier: "BoatCell")
        refresh()
    }
    
    @objc func jobsButtonPressed (_ sender: Any) {
        performSegue(withIdentifier: "JobSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? JobViewController {
            vc.townModel = townController.model
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return townController.model.boats.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let map = MapViewController.instance
        map.boatSelected(boat: map.boatControllerForModel(model: townController.model.boats[indexPath.row]))
        navigationController?.popViewController(animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoatCell", for: indexPath) as! BoatCellView
        
        let boat = townController.model.boats[indexPath.row]
        cell.boatName.text = boat.name
        
        let imageName = UIImage(named: boat.type + "_01")
        cell.imageView?.image = imageName
        
        return cell
    }
    
    func refresh () {
        sizeLabel.text = String(townController.model.level)
        if townController!.model.level == 0 {
            upgradeButton.setBackgroundColor(UIColor.red, for: .normal)
            upgradeButton.setTitle("Unlock", for: .normal)
        } else {
            upgradeButton.setBackgroundColor(UIColor.blue, for: .normal)
            upgradeButton.setTitle("Upgrade", for: .normal)
        }
        let cost = getCost()
        costLabel.text = String(cost)
        if townController!.model.level > TownModel.maxLevel {
            upgradeButton.isEnabled = false
            costLabel.textColor = .orange
            costLabel.text = "Maximum"
        } else if User.sharedInstance.silver < cost {
            upgradeButton.isEnabled = false
            costLabel.textColor = .red
        }
    }
    
    func getCost( ) -> Int {
        var cost : Int
        if townController!.model.level == 0 {
            cost = townController.model.purchaseCost
        } else {
            cost = townController.model.upgradeCost
        }
        return cost
    }
    
    @IBAction func upgradeButtonPressed(_ sender: Any) {
        User.sharedInstance.addMoney(gold: 0, silver: -getCost())
        townController.model.level += 1
        NotificationCenter.default.post(name: NSNotification.Name.townUpgraded, object: self, userInfo: ["town" : self])
        refresh()
        User.sharedInstance.save()
        townController.reset()
    }
    
}
