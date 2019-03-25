//
//  MapListController.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 5/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class BoatListController: UIViewController {
    
    @IBOutlet weak var boatList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boatList.dataSource = self
        boatList.delegate = self
        boatList.register(UINib(nibName: "BoatCell", bundle: nil), forCellReuseIdentifier: "BoatCell")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(boatArrived(_:)),
                                               name: Notification.Name.boatArrived, object: nil)
    }
    
    @objc func boatArrived(_ notification: Notification) {
        let boat = notification.userInfo!["Boat"] as! BoatModel
        for case let cell as BoatCellView in boatList.visibleCells {
            if cell.boat === boat {
                updateCell(cell: cell)
            }
        }
    }
    
    func updateCell ( cell: BoatCellView ) {
        if let boat = cell.boat {
            cell.boatName.text = boat.name
            if boat.isMoored == true {
                cell.boatStatus.text = "Moored at " + boat.town!.name
            } else {
                cell.boatStatus.text = "Sailing to " + boat.destination!.name
            }
            let imageName = UIImage(named: boat.type + "_01")
            cell.imageView?.image = imageName
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        boatList.reloadData()
    }
    
}

extension BoatListController : UITableViewDelegate
{
    
}

extension BoatListController : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.sharedInstance.boatSlots + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let map = (tabBarController!.viewControllers![0] as! UINavigationController)
            .viewControllers[0] as! MapViewController
        
        let user = User.sharedInstance
        if indexPath.row < user.numBoats {
            map.boatSelected(with: indexPath.row)
            tabBarController!.selectedIndex = 0
        } else if indexPath.row < user.boatSlots {
        } else {
            let alert = UIAlertController(title: "Expand Fleet", message: nil , preferredStyle: UIAlertController.Style.alert)
            if user.silver >= user.boatSlotCost {
                alert.message = "Buy extra boat slot for " + String(user.boatSlotCost) + " silver"
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
                    user.addMoney(gold: 0, silver: -user.boatSlotCost)
                    user.boatSlots += 1
                    tableView.reloadData()
                    user.save()
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            } else {
                alert.message = "You do not have enough silver to purchase this boat slot"
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            }
            AlertQueue.shared.pushAlert(alert)
            //self.present(alert, animated: true)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.setSelected(false, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let user = User.sharedInstance
        if indexPath.row >= user.numBoats || user.boats[indexPath.row].isMoored == false || user.numBoats == 1 {
            return false
        }
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let boat = User.sharedInstance.boats[indexPath.row]

        let sell = UITableViewRowAction(style: .destructive, title: "Sell") { (action, indexPath) in
            let alert = UIAlertController(title: "Sell Boat", message: "Sell " + boat.title + " for " +
                String(boat.value * User.exchangeRate) + "?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(UIAlertAction) in
                User.sharedInstance.removeBoat(boat)
                User.sharedInstance.addMoney(gold: 0, silver: boat.value * User.exchangeRate)
                User.sharedInstance.save()
                tableView.reloadData()
            }))
            AlertQueue.shared.pushAlert(alert)
        }
        
        return [sell]
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! BoatCellView
        cell.backgroundColor = UIColor.white
        cell.isUserInteractionEnabled = true
        if indexPath.row < User.sharedInstance.numBoats {
            cell.boat = User.sharedInstance.boatAtIndex(indexPath.row)
            cell.optionsStack.isHidden = true
            cell.boatName.isHidden = false
            cell.boatStatus.isHidden = false
            cell.imageView?.isHidden = false
            updateCell(cell: cell)
        } else {
            cell.optionsStack.isHidden = false
            cell.boatName.isHidden = true
            cell.boatStatus.isHidden = true
            cell.imageView?.isHidden = true
            if indexPath.row < User.sharedInstance.boatSlots {
                cell.promptLabel.text = "Empty Slot"
                cell.moneyImage.isHidden = true
                cell.costLabel.isHidden = true
                cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
                cell.isUserInteractionEnabled = false
            } else {
                cell.promptLabel.text = "Purchase Extra Slot"
                cell.costLabel.text = String(User.sharedInstance.boatSlotCost)
                cell.moneyImage.isHidden = false
                cell.costLabel.isHidden = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoatCell", for: indexPath) as! BoatCellView
        return cell
    }
    func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        let nib = UINib(nibName: "TableHeader", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
        let label1 = nib.viewWithTag(1) as! UILabel
        let label2 = nib.viewWithTag(2) as! UILabel
        label1.text = "Boats"
        label2.isHidden = true
        
        return nib
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0))
    }
    
}

