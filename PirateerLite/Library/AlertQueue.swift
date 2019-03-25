//
//  AlertQueue.swift
//  ClearForActionLite
//
//  Created by Peter Respondek on 17/3/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class AlertQueue
{
    struct Alert {
        var controller : UIAlertController
        var presentClosure : (() -> Void)?
    }
    static let shared = AlertQueue()
    private var _alerts = Array<Alert>()
    private var _alert : Alert?
    
    func pushAlert(_ alert: UIAlertController, onPresent: (() -> Void)? = nil) {
        _alerts.append(Alert(controller: alert, presentClosure: onPresent))
        presentAlert()
    }
    
    private func presentAlert () {
        if _alerts.isEmpty || _alert != nil { return }
        
        if let appDelegate = UIApplication.shared.delegate,
            let appWindow = appDelegate.window!,
            let rootViewController = appWindow.rootViewController {
            _alert = self._alerts.popLast()!
            rootViewController.present(_alert!.controller, animated: true, completion: {
                self._alert = nil
                self.presentAlert()
            })
            if let closure = _alert!.presentClosure {
                closure()
            }
        }
    }
    
    private init ()
    {
        
    }
}
