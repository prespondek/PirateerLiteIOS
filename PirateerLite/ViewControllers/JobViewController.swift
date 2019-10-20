//
//  JobViewController.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 17/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class JobViewController : UIViewController, UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    CargoViewDelegate, TownDelegate
{
    func jobsUpdated() {
        
    }
    
    @IBOutlet weak var goldLabel:   UILabel!
    @IBOutlet weak var silverLabel: UILabel!
    @IBOutlet weak var jobView:     UICollectionView!
    @IBOutlet weak var cargoPanel:  UIView!
    @IBOutlet weak var cargoView:   CargoView!
    
    var boatController :            BoatController!
    var townModel :                 TownModel!

    private var _jobs :             Array<JobModel>!
    private var _cargo :            Array<JobView>!
    private var _size :             CGFloat!
    private var _storage :          Array<JobModel?>!
    private var _refreshControl =   UIRefreshControl()
    private var _jobTimer:          Timer?
    
    var jobs : Array<JobModel> {
        return _jobs
    }
    
    @objc func jobDelivered(_ notification: Notification) {
        let boat = notification.userInfo!["Boat"] as! BoatModel
        if boat === boatController.model {
            jobView.reloadData()
        }
    }

    @objc func boatArrived(_ notification: Notification) {
        let boat = notification.userInfo!["Boat"] as! BoatModel
        if boat === boatController.model {
            NotificationCenter.default.removeObserver(self)
            viewDidLoad()
            jobView.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        jobView.dataSource = self
        jobView.delegate = self
        if UIDevice.current.userInterfaceIdiom == .pad{
            _size = jobView.bounds.width / 6
        } else {
            _size = jobView.bounds.width / 3 - 10
        }
        if boatController == nil {
            cargoPanel.isHidden = true
            self._jobs = townModel.jobs
            self._storage = townModel.storage
            _refreshControl.addTarget(self, action: #selector(reloadJobs(_:)), for: UIControl.Event.valueChanged)
            jobView.addSubview(_refreshControl)
        }
        else if boatController.isSailing == false {
            self.townModel = boatController.model.town!
            townModel.delegate = self
            self._jobs = townModel.jobs
            self._storage = townModel.storage
            self.cargoPanel.layer.shadowColor = UIColor.black.cgColor
            self.cargoPanel.layer.shadowOpacity = 0.3
            self.cargoPanel.layer.shadowOffset = CGSize(width: 0, height: -6)
            self.cargoPanel.layer.shadowRadius = 4
            self.cargoPanel.layer.masksToBounds = false
        
            _cargo = self.cargoView.setup(height: _size, boat: boatController)
            for cargo in _cargo {
                let gesture1 = UISwipeGestureRecognizer(target: self, action: #selector(cargoSwipe(_:)))
                cargo.addGestureRecognizer(gesture1)
                gesture1.direction = .left
                let gesture2 = UITapGestureRecognizer(target: self, action: #selector(cargoTouch(_:)))
                cargo.addGestureRecognizer(gesture2)
                cargo.isUserInteractionEnabled = false
            }
            _refreshControl.addTarget(self, action: #selector(reloadJobs(_:)), for: UIControl.Event.valueChanged)
            jobView.addSubview(_refreshControl)
            _cargo.last?.isUserInteractionEnabled = true
            cargoView.delegate = self
            cargoPanel.isHidden = false
            updateCargoValue()
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(jobDelivered(_:)),
                                                   name: Notification.Name.jobDelivered, object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(boatArrived(_:)),
                                                   name: Notification.Name.boatArrived, object: nil)
            cargoPanel.isHidden = true
        }
    }
    
    @objc private func reloadJobs(_ sender: Any) {
        if boatController != nil {
            _jobs = townModel.jobs
        } else {
            _jobs = townModel.jobs
        }
        jobView.reloadData()
        _refreshControl.endRefreshing()
        updateCargoValue()
    }

    override func willMove(toParent parent: UIViewController?) {
        if boatController != nil && parent == nil && boatController.isSailing == false {
            boatController.model.setCargo(jobs: cargoView.jobs)
            townModel.setStorage(jobs: _storage)
        }
        super.willMove(toParent: parent)
    }
    
    @IBAction private func cargoTouch( _ sender: UIGestureRecognizer ) {
        if let view = _cargo.last {
            if let job = view.job {
                if let idx = _jobs.firstIndex(where: {$0 === job}) {
                    if let cell = jobView.cellForItem(at: IndexPath(row: idx, section: 0)) {
                        let content = cell.subviews[0].subviews[0].subviews[0] as! JobView
                        content.job = job
                    }
                } else if let idx = _storage.firstIndex(where: {$0 == nil}) {
                    if let cell = jobView.cellForItem(at: IndexPath(row: idx, section: 1)) {
                        let content = cell.subviews[0].subviews[0].subviews[0] as! JobView
                        content.job = job
                    }
                    _storage[idx] = job
                }
                cargoView.removeJob(job: view.job!)
                AudioManager.sharedInstance.playSound(sound: "button_select")
                updateCargoValue()
            }
        }
    }
    
    @IBAction private func cargoSwipe( _ sender: UIGestureRecognizer ) {
        if let view = _cargo.popLast() {
            self.cargoView.swipeStarted(view: view)
            view.isUserInteractionEnabled = false
            _cargo.insert(view, at: 0)
        }
    }
    
    func swipeFinished(view: JobView) {
        if let view = _cargo.first {
            view.isUserInteractionEnabled = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        let content = cell.subviews[0].subviews[0].subviews[0] as! JobView
        if indexPath.section == 0 {
            if boatController == nil {
                let job = self._jobs[indexPath.row]
                content.job = job
            } else if townModel == nil {
                let job = self.boatController.model.cargo[indexPath.row]
                let jobs = self.boatController.model.cargo.map {
                    $0 != nil && job != nil && $0! !== job! && job!.destination === $0!.destination }
                if jobs.count == self.boatController.model.cargoSize {
                    content.bonus(true)
                } else {
                    content.bonus(false)
                }
                content.job = job
            } else {
                let job = self._jobs[indexPath.row]
                if _cargo.contains(where: {$0.job === job}) {
                    content.job = nil
                } else {
                    content.job = job
                }
                content.bonus(false)
            }
        } else if indexPath.section == 1 {
            if indexPath.row < _storage.count {
                let job = self._storage[indexPath.row]
                content.job = job
            } else {
                content.job = nil
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            if townModel == nil {
                return boatController.model.cargo.count
            } else {
                return self._jobs.count
            }
        } else if section == 1 {
            return townModel.storageSize
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = jobView.dequeueReusableCell(withReuseIdentifier: "JobCell", for: indexPath)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if townModel == nil {
            return 1
        }
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        let label = view.subviews[0] as! UILabel
        let label2 = view.subviews[1] as! UILabel
        label2.isHidden = true
        if indexPath.section == 0 {
            if townModel == nil {
                label.text = "Cargo"
            } else {
                label2.isHidden = false
                label.text = "Jobs"
                updateJobTimer(label: label2)
                _jobTimer?.invalidate()
                _jobTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (time: Timer) in
                    if self != nil {
                        self!.updateJobTimer(label: label2)
                    }
                })
            }
        } else {
            label.text = "Storage"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let cell = jobView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "JobSelectionLabel", for: indexPath)
        return cell
    }
    
    private func updateJobTimer(label: UILabel) {
        if townModel.jobsDirty == false {
             var diff = (User.jobInterval - (Date().timeIntervalSince1970 - User.sharedInstance.jobDate.timeIntervalSince1970)) / 60
            let remainer = (Double(Int(diff)), (diff - Double(Int(diff))) * 0.6)
            diff = remainer.0 + remainer.1
            label.text = String(format: "New stock in %.2f minutes", diff)
        } else {
            label.text = String(format: "New stock available")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath)?.subviews[0].subviews[0].subviews[0] as? JobView {
            if townModel != nil {
                cell.highlighted()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath)?.subviews[0].subviews[0].subviews[0] as? JobView {
            if townModel != nil {
                cell.unhighlighted()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath)?.subviews[0].subviews[0].subviews[0] as? JobView {
            if townModel == nil || boatController == nil { return }

            if cargoView.jobs.filter({$0 != nil}).count < boatController.model.cargoSize && cell.job != nil {
                cargoView.addJob(job: cell.job!)
                cell.job = nil
                AudioManager.sharedInstance.playSound(sound: "button_select")
                if indexPath.section == 1 {
                    _storage[indexPath.row] = nil
                }
            } else {
            }
            updateCargoValue()
        }
    }
    
    func updateCargoValue () {
        let value = cargoView.cargoValue
        goldLabel.text = String(value.0)
        silverLabel.text = String(value.1)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad{
            // here return cell size for iPad.
            return CGSize( width:_size , height:_size )
        }else{
            // here return cell size for iPhone
            return CGSize( width:_size, height:_size )
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        _jobTimer?.invalidate()
        _jobTimer = nil
    }
}
