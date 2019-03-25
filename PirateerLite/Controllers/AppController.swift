//
//  AppController.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 31/1/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import UIKit

class AppViewController: UITabBarController {
    var mapController : MapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapController = viewControllers?[0] as? MapViewController
    }
}
