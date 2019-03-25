//
//  MarketViewController.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 24/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class MarketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserObserver {
    func goldUpdated(oldValue: Int, newValue: Int) {
        moneyUpdated ()
    }
    
    func silverUpdated(oldValue: Int, newValue: Int) {
        moneyUpdated ()
    }
    func xpUpdated(oldValue: Int, newValue: Int) {}
    
    @IBOutlet weak var marketView: UITableView!
    @IBOutlet weak var walletView: WalletView!
    
    
    private var _parts : Array<User.BoatPart>!
    private var _marketTimeStamp : Date!
    private var _marketTimer: Timer?
    private var _refreshControl = UIRefreshControl()
    var selectedPart : User.BoatPart?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        User.sharedInstance.addObserver(self)
        _parts = User.sharedInstance.market
        _marketTimeStamp = User.sharedInstance.marketDate
        marketView.delegate = self
        marketView.dataSource = self
        _refreshControl.addTarget(self, action: #selector(reloadMarket(_:)), for: UIControl.Event.valueChanged)
        marketView.addSubview(_refreshControl)
    }
    
    @objc private func reloadMarket(_ sender: Any) {
        _parts = User.sharedInstance.market
        _marketTimeStamp = User.sharedInstance.marketDate
        marketView.reloadData()
        _refreshControl.endRefreshing()
    }
    
    deinit {
        User.sharedInstance.removeObserver(self)
    }
    
    private func moneyUpdated () {
        for cell in marketView.visibleCells {
            if cell.isSelected { continue }
            let mcell = cell as! MarketCellView
            mcell.update()
        }
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _parts.count
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPart = _parts[indexPath.row]
        if selectedPart!.item != .boat {
            let boatInfo = BoatModel.boatValues[selectedPart!.boat]!
            User.sharedInstance.parts.append(selectedPart!)
            if _marketTimeStamp == User.sharedInstance.marketDate {
                User.sharedInstance.removePart(part:selectedPart!)
            }
            _parts.remove(at: indexPath.row)
            User.sharedInstance.addMoney(gold: -(boatInfo[BoatModel.BoatIndex.part_cost.rawValue] as! Array<Int>)[selectedPart!.item.rawValue], silver: 0)                
            tableView.reloadData()
            User.sharedInstance.save()
        } else if  User.sharedInstance.numBoats >= User.sharedInstance.boatSlots {
            let alert = UIAlertController(title: "Purchase Boat", message: "You do not have enough boat slots. Purchase more space from the boat menu." , preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
            //self.present(alert, animated: true)
            AlertQueue.shared.pushAlert(alert)
            tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        } else {
            performSegue(withIdentifier: "unwindSegueToMap", sender: selectedPart)
        }
    }
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedItems = marketView!.indexPathsForSelectedRows {
            for item in selectedItems {
                marketView.deselectRow(at: item, animated: false)
            }
        }
    }
    
    private func updateMarketTimer(label: UILabel) {
        if _marketTimeStamp == User.sharedInstance.marketDate {
            var diff = (User.marketInterval - (Date().timeIntervalSince1970 - User.sharedInstance.marketDate.timeIntervalSince1970)) / 60
            let remainer = (Double(Int(diff)), (diff - Double(Int(diff))) * 0.6)
            diff = remainer.0 + remainer.1
            label.text = String(format: "New stock in %.2f minutes", diff)
        } else {
            label.text = String(format: "New stock available")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let label1 = view.viewWithTag(1) as! UILabel
        let label2 = view.viewWithTag(2) as! UILabel
        label1.text = "Market"
        updateMarketTimer(label: label2)
        _marketTimer?.invalidate()
        _marketTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (time: Timer) in
            self?.updateMarketTimer(label: label2)
        })
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! MarketCellView
        cell.setup(part: _parts[indexPath.row])
        
    }
    
    internal func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        let nib = UINib(nibName: "TableHeader", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
        return nib
        
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0))
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarketCell", for: indexPath)
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        _marketTimer?.invalidate()
        _marketTimer = nil
    }
    
}
