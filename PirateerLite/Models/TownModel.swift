//
//  TownModel.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 31/1/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class WorldNode {
    
}

protocol TownDelegate {
    func jobsUpdated ()
}

class TownModel : WorldNode, Hashable, Codable, UserObserver {
    static func == (lhs: TownModel, rhs: TownModel) -> Bool {
        return lhs.name == rhs.name
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    enum CodingKeys: String, CodingKey
    {
        case level
        case _jobs
        case _storage
        case _jobsTimeStamp
        case _stats
    }

    enum TownType : String {
        case
        island =        "island",
        castle =        "castle",
        pub =           "pub",
        village =       "village",
        lighthouse =    "lighthouse",
        prison =        "prison",
        fishermen =     "fishermen",
        mansion =       "mansion",
        homestead =     "homestead"
    }
    
    enum HarbourSize : String {
        case
        large =         "marina",
        medium =        "docks",
        small =         "pier"
        
        static func <(left: TownModel.HarbourSize, right: TownModel.HarbourSize) -> Bool {
            return (left == .small && (right == .medium || right == .large)) ||
                    (left == .medium && right == .large)
        }
        static func >(left: TownModel.HarbourSize, right: TownModel.HarbourSize) -> Bool {
            return (left == .large && (right == .small || right == .medium)) ||
                (left == .medium && right == .small)
        }
    }

    enum Allegiance : String {
        case
        none =          "none",
        england =       "british",
        american =      "american",
        spanish =       "spanish",
        french =        "french"
    }
    private static var townCost : Array<Int>!
    private static var townUpgrade : Array<Array<Int>>!
    static func setGlobals (townCost: Array<Int>, townUpgrade: Array<Array<Int>>) {
        TownModel.townCost = townCost
        TownModel.townUpgrade = townUpgrade
    }
    var type = TownType(rawValue: "island")!
    var allegiance = Allegiance (rawValue: "british")!
    var description = ""
    var name = ""
    var color = UIColor.black
    var harbour = HarbourSize(rawValue: "pier")!
    var delegate : TownDelegate?
    private var _boats = Array<BoatModel>()
    private var _jobs : Array<JobModel>
    private var _storage : Array<JobModel?>
    private var _jobsTimeStamp : Date
    private var _stats : TownStats
    var storage : Array<JobModel?> {
        return _storage
    }
    var stats : TownStats {
        return _stats
    }
    var jobs : Array<JobModel>? {
        get {
            if level == 0 {
                return nil
            }
            if _jobsTimeStamp != User.sharedInstance.jobDate {
                refreshJobs()
            }
            return _jobs
        }
    }
    var jobsDirty : Bool {
        return _jobsTimeStamp != User.sharedInstance.jobDate
    }
    var jobsSize : Int {
        return TownModel.townUpgrade[level][0]
    }
    var storageSize : Int {
        return TownModel.townUpgrade[level][1]
    }
    
    var level : Int {
        didSet (oldvalue){
            if level > TownModel.maxLevel {
                level = TownModel.maxLevel
            }
            while _storage.count < TownModel.townUpgrade[level][1] {
                _storage.append(nil)
            }
        }
    }
    static var maxLevel : Int {
        return TownModel.townUpgrade.count - 1
    }
    var purchaseCost : Int {
        get {
            var idx = 0
            switch ( harbour ) {
                case .small: idx = 0
                case .medium: idx = 1
                case .large: idx = 2
            }
            return TownModel.townCost![idx]
        }
    }
    var boats : Array<BoatModel> {
        get {
            return _boats
        }
    }
    func setStorage (jobs: Array<JobModel?>) {
        if jobs.count <= _storage.count {
            _storage = jobs
        } else {
            fatalError("TownModel:setStorage: index out of range")
        }
    }
    
    var upgradeCost : Int {
        get {
            var val = 0
            switch ( level ) {
                case 1: val = purchaseCost / 2
                case 2: val = purchaseCost
                case 3: val = purchaseCost * 2
                default: val = purchaseCost
            }
            return val
        }
    }
    
    func removeJob(job: JobModel) {
        _jobs.removeAll(where: {$0 === job})
        if job.isGold {
            stats.startGold += Int(job.value)
        } else {
            stats.startSilver += Int(job.value)
        }
    }
    
    private func refreshJobs () {
        _jobs.removeAll()
        var unlockedTowns = Map.sharedInstance.towns.filter({$0.level > 0})
        unlockedTowns.removeAll(where: {$0 === self})
        var numJobs = TownModel.townUpgrade[level][0]
        unlockedTowns.forEach {
            for _ in 0..<$0.level - 1 {
                unlockedTowns.append($0)
            }
        }
        if numJobs > unlockedTowns.count {
            numJobs = unlockedTowns.count
        }
        for _ in 0..<numJobs {
            let roll = unlockedTowns.randomElement()!
            let job = JobModel(source:self,destination:roll)
            _jobs.append(job)
        }
        _jobsTimeStamp = User.sharedInstance.jobDate
        delegate?.jobsUpdated()
    }

    
    func boatArrived (boat: BoatModel) {
        self._boats.append(boat)
        self._stats.totalVisits += 1
    }
    
    func boatDeparted (boat: BoatModel) {
        self._boats.removeAll(where: {$0 === boat})
    }
    
    init( data: Array<Any>) {
        level =         0
        _jobs =         Array<JobModel>()
        _storage =      Array<JobModel?>()
        _jobsTimeStamp = Date()
        _stats = TownStats()
        super.init()
    }
    
    func setup ( data: Array<Any> ) {
        name =          data[0] as! String
        allegiance =    Allegiance(rawValue: data[1] as! String)!
        type =          TownType(rawValue:data[2] as! String)!
        description =   data[3] as! String
        harbour =       HarbourSize(rawValue:data[4] as! String)!
        color =         UIColor(hex: data[5] as! String)
        _boats =        Array<BoatModel>()
    }
    
    func addBoat(_ boat: BoatModel) {
        _boats.append(boat)
    }
    func removeBoat(_ boat: BoatModel) {
        _boats.removeAll(where: {$0 === boat})
    }
    
    func jobDelivered(_ job: JobModel) {
        if job.isGold {
            stats.endGold += Int(job.value)
        } else {
            stats.endSilver += Int(job.value)
        }
    }
}

class TownStats : Codable
{
    var totalVisits : Int
    var startSilver : Int
    var endSilver : Int
    var startGold : Int
    var endGold : Int
    
    init() {
        self.totalVisits = 0
        self.startSilver = 0
        self.endSilver = 0
        self.startGold = 0
        self.endGold = 0
    }
}
