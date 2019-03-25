//
//  BoatCellView.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 15/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class BoatCellView: UITableViewCell {
    @IBOutlet weak var optionsStack: UIStackView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var boatName: UILabel!
    @IBOutlet weak var moneyImage: UIImageView!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var boatStatus: UILabel!
    weak var boat : BoatModel?
}
