//
//  ShipyardViewController.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 24/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class ShipyardViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BoatModel.boatKeys.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! ShipyardCellView
        let name = BoatModel.boatKeys[indexPath.row]
        cell.setBoatData(name: name, data: BoatModel.boatValues[name]!)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShipyardCell", for: indexPath)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //tabBarController?.tabBar.isHidden = true
        if let vc = segue.destination as? BoatInfoViewController
        {
            let cell = sender as! ShipyardCellView
            vc.boatType = cell.boatName
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        let nib = UINib(nibName: "TableHeader", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
        let label1 = nib.viewWithTag(1) as! UILabel
        let label2 = nib.viewWithTag(2) as! UILabel
        label1.text = "Shipyard"
        label2.isHidden = true
        return nib
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0))
    }
    
}
