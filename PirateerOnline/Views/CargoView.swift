//
//  CargoView.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 19/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

protocol CargoViewDelegate : class {
    func swipeFinished( view: JobView )
}

class CargoView : UIView {
    @IBOutlet weak var cargoHeight: NSLayoutConstraint!
    private var _orderDistance : CGFloat = 0
    private var _views : Array<JobView>!
    weak var delegate : CargoViewDelegate?
    var jobs : Array<JobModel?> {
        return _views.map({$0.job})
    }
    var cargoValue : (Int,Int) {
        var gold = 0
        var silver = 0
        var destinations = Set<TownModel?>()
        for job in jobs {
            destinations.insert(job?.destination)
            if let job = job {
                if job.isGold {
                    gold += Int(job.value)
                } else {
                    silver += Int(job.value)
                }
            }
        }
        if destinations.count == 1 && destinations.first != nil {
            gold = Int(Double(gold) * 1.25)
            silver = Int(Double(silver) * 1.25)
        }
        return (gold,silver)
    }
    
    func setup ( height: CGFloat, boat: BoatController ) -> Array<JobView> {
        cargoHeight.constant = height + 16
        layer.cornerRadius = 16
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5
        self.layoutIfNeeded()
        var views = Array<JobView>()
        for i in 0..<boat.model.cargoSize {
            let nib = Bundle.main.loadNibNamed("JobCell", owner: self, options: nil)![0] as! JobView
            nib.job = nil
            nib.frame.size = CGSize(width: height , height: height)
            addSubview(nib)
            nib.center = CGPoint(
                x: self.frame.width / 2 + CGFloat(i) * nib.frame.width * 0.125,
                y: self.frame.height / 2 )
            views.append(nib)
        }
        var idx = 0
        for job in boat.model.cargo {
            views[idx].job = job
            idx += 1
        }
        _views = views
        _orderDistance = CGFloat(boat.model.cargoSize)
        _ = updateCells()
        return views
    }
    
    func swipeStarted ( view: JobView ) {
        UIView.animate( withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            view.center.x = self.frame.width / 2 - view.frame.width
        }, completion: { ( finished: Bool ) in
            view.layer.zPosition = 0
            UIView.animate( withDuration: 0.125, delay: 0, options: .curveEaseIn, animations: {
                view.center.x = self.frame.width / 2
            }, completion: { ( finished: Bool ) in
                let last = self._views.popLast()
                self._views.insert(last!, at: 0)
                self.delegate?.swipeFinished(view: view)
            })
        })
        for jobView in _views {
            print(jobView.layer.zPosition)
            if view === jobView { continue }
            UIView.animate( withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                jobView.center.x += view.frame.width * 0.125
            }, completion: { ( finished: Bool ) in
                jobView.layer.zPosition += 1
            })
        }
    }
    
    func addJob ( job: JobModel ) {
        if _views.lastIndex(where: {$0.job === job}) == nil {
            let view = _views.last(where: {$0.job === nil})
            view?.job = job
            if updateCells() {
                AudioManager.sharedInstance.playSound(sound: "cargo_bonus")
            }
        }
    }
    
    func updateCells () -> Bool {
        var bonus = false
        for view in _views {
            let views = _views.filter { $0.job != nil && $0.job?.destination === view.job?.destination }
            if views.count == _views.count {
                for cell in views {
                    cell.bonus(true)
                    bonus = true
                }
            }  else {
                view.bonus(false)
            }
        }
        return bonus
    }
    
    func removeJob ( job: JobModel )
    {
        if let idx = _views.lastIndex(where: {$0.job === job}) {
            _views[idx].job = nil
            _ = updateCells()
        }
    }
}
