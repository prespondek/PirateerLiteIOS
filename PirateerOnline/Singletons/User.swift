//
//  UserModel.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 3/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

protocol UserObserver : class {
    func goldUpdated    (oldValue: Int, newValue: Int)
    func silverUpdated  (oldValue: Int, newValue: Int)
    func xpUpdated      (oldValue: Int, newValue: Int)
    func boatAdded      (boat: BoatModel)
    func boatRemoved    (boat: BoatModel)
    func statsUpdated   ()
}

extension UserObserver {
    func goldUpdated    (oldValue: Int, newValue: Int) {}
    func silverUpdated  (oldValue: Int, newValue: Int) {}
    func xpUpdated      (oldValue: Int, newValue: Int) {}
    func boatAdded      (boat: BoatModel) {}
    func boatRemoved    (boat: BoatModel) {}
    func statsUpdated   () {}
}

class User : Codable {
    enum CodingKeys: String, CodingKey
    {
        case xp,parts,_market,_boatModels,_marketDate,_jobDate,gold,silver,boatSlots,_stats,_startDate
    }
    
    enum MarketItem : Int, Codable  {
        case hull = 0, rigging, sails, cannon, boat
    }
    
    class Stats : Codable
    {
        var distance :  Double = 0
        var voyages :   Int = 0
        var silver :    Int = 0
        var gold :      Int = 0
        var time :      TimeInterval = 0
        var boatsSold : Int = 0
        var boatStats = Dictionary<String,BoatArchive>()
        
        init() {
            boatStats["maxDistance"] = BoatArchive()
            boatStats["maxProfit"] = BoatArchive()
            boatStats["SPM"] = BoatArchive()
            boatStats["maxVoyages"] = BoatArchive()
        }
    }
    
    struct BoatArchive : Codable
    {
        var name : String
        var type : String
        var stats : BoatStats
        
        init() {
            name = "---"
            type = ""
            stats = BoatStats()
        }
        
        init(_ boat: BoatModel) {
            name = boat.name
            type = boat.type
            stats = boat.stats
        }
    }
    
    class BoatPart : Codable  {
        init(boat: String, item: MarketItem) {
            self.boat = boat
            self.item = item
        }
        var boat: String
        var item: MarketItem
        static func == (lhs: BoatPart, rhs: BoatPart) -> Bool {
            return lhs.boat == rhs.boat && lhs.item == rhs.item
        }
    }
    
    static var JSONPath : URL {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path += "/user.json"
        return URL(fileURLWithPath: path)
    }
    
    func save () {
        DispatchQueue.global(qos: .background).async(execute: { [weak self] in
            do {
                var encodedData = try? JSONEncoder().encode(self)
                try encodedData?.write(to: User.JSONPath)
                encodedData = try? JSONEncoder().encode(Map.sharedInstance)
                try encodedData?.write(to: Map.JSONPath)
            } catch {
                print ("save failed")
            }
        })

    }
    
    var levelXp : Int {
        return xpForLevel(self.level)
    }
    
    var startDate : Date {
        return _startDate
    }
    
    func xpForLevel (_ level: Int) -> Int {
        return Int(exp2f(Float(level + 1)) * 1500)
    }
    
    var level : Int {
        return levelForXp(self.xp)
    }
    
    func levelForXp (_ xp: Int) -> Int {
        return Int(max(0,log2(Float(xp) / 1500)))
    }
    
    static private let userData : Dictionary<String, Any> = {
        do {
            return try JSONSerialization.load(path: "PirateerAssets/user_model.json") as! Dictionary<String, AnyObject>
        } catch {
            fatalError()
        }
    }()
    static var boatKeys : Array<String> {
        return userData["Boats"] as! Array<String>
    }
    static var rankKeys : Array<String> {
        return userData["RankKeys"] as! Array<String>
    }
    static var rankValues : Dictionary<String, Array<Any>> {
        return userData["RankValues"] as! Dictionary<String, Array<Any>>
    }
    static var exchangeRate : Int {
        return userData["ExchangeRate"] as! Int
    }
    static var jobInterval : TimeInterval {
        return userData["JobTime"] as! TimeInterval
    }
    static var marketInterval : TimeInterval {
        return userData["MarketTime"] as! TimeInterval
    }
    struct ObserverContainer {
        weak var observer : UserObserver?
    }
    
    var gold : Int {
        didSet (oldvalue) {
            cleanObservers()
            if oldvalue != gold {
                for container in _observers {
                    container.observer!.goldUpdated(oldValue: oldvalue, newValue: gold)
                }
            }
        }
    }
    var silver : Int {
        didSet (oldvalue) {
            cleanObservers()
            if oldvalue != silver {
                for container in _observers {
                    container.observer!.silverUpdated(oldValue: oldvalue, newValue: silver)
                }
            }
        }
    }
    
    func statsUpdated ()
    {
        cleanObservers()
        for container in _observers {
            container.observer!.statsUpdated()
        }
    }
    
    func addMoney( gold: Int, silver: Int)
    {
        self.gold += gold
        self.silver += silver
        if gold != 0 || silver != 0 {
            AudioManager.sharedInstance.playSound(sound:"silver_large")
        }
        User.sharedInstance.stats.silver += silver
        User.sharedInstance.stats.gold += gold
        statsUpdated()
    }
    
    var xp : Int {
        didSet (oldvalue) {
            cleanObservers()
            for container in _observers {
                container.observer!.xpUpdated(oldValue: oldvalue, newValue: silver)
            }
            if levelForXp(oldvalue) != levelForXp(xp) {
                let alert = UIAlertController(title: "Level Up", message: "Newer boats are available for you to build. Shipyard and market have been updated." , preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .default, handler:nil))
                AlertQueue.shared.pushAlert(alert, onPresent: {
                    AudioManager.sharedInstance.playSound(sound: "level_up")
                })
            }
        }
    }
    
    var boatSlotCost : Int {
        var val = 1024
        for _ in 0..<boatSlots {
            val += val / 2
        }
        return val
    }
    
    var stats : Stats {
        return _stats
    }
    
    var parts : Array<BoatPart>
    private var _market : Array<BoatPart>
    var boatSlots : Int
    private var _stats : Stats
    private var _boatModels : Array<BoatModel>
    private var _observers = Array<ObserverContainer>()
    private static var _user : User?
    private var _marketDate : Date
    private var _jobDate : Date
    private var _startDate : Date
    
    required init(from decoder: Decoder) throws
    {
        let values =    try decoder.container(keyedBy: CodingKeys.self)
        xp =            try values.decode(Int.self, forKey: .xp)
        _market =       try values.decode(Array<BoatPart>.self, forKey: ._market)
        parts =         try values.decode(Array<BoatPart>.self, forKey: .parts)
        _boatModels =   try values.decode(Array<BoatModel>.self, forKey: ._boatModels)
        _marketDate =   try values.decode(Date.self, forKey: ._marketDate)
        _jobDate =      try values.decode(Date.self, forKey: ._jobDate)
        gold =          try values.decode(Int.self, forKey: .gold)
        silver =        try values.decode(Int.self, forKey: .silver)
        _stats =        try values.decode(Stats.self, forKey: ._stats)
        _startDate =    try values.decode(Date.self, forKey: ._startDate)
        for boat in _boatModels {
            if let town = boat.town {
                town.addBoat(boat)
            }
        }
        boatSlots =     try values.decode(Int.self, forKey: .boatSlots)
    }
    
    static var sharedInstance : User {
        if let user = _user {
            return user
        } else {
            do {
                _user = try JSONDecoder().decode(User.self, from: Data(contentsOf: User.JSONPath))
            } catch {
                _user = User()
            }
            return _user!
        }
    }
    
    func boatArrived (_ boat: BoatModel) {
        stats.distance += boat.courseDistance
        stats.time += boat.courseTime
        stats.voyages += 1
        if boat.stats.totalDistance > stats.boatStats["maxDistance"]!.stats.totalDistance {
            stats.boatStats["maxDistance"] = BoatArchive(boat)
        }
        if boat.stats.SPM > stats.boatStats["SPM"]!.stats.SPM {
            stats.boatStats["SPM"] = BoatArchive(boat)
        }
        if boat.stats.totalSilver > stats.boatStats["maxProfit"]!.stats.totalSilver {
            stats.boatStats["maxProfit"] = BoatArchive(boat)
        }
        if boat.stats.totalVoyages > stats.boatStats["maxVoyages"]!.stats.totalVoyages {
            stats.boatStats["maxVoyages"] = BoatArchive(boat)
        }
        statsUpdated()
    }
    
    func addObserver(_ observer: UserObserver) {
        _observers.append(ObserverContainer(observer: observer))
    }
    
    func removeObserver(_ observer: UserObserver) {
        cleanObservers()
        _observers.removeAll { $0.observer === observer }
    }
    
    private func cleanObservers() {
        _observers.removeAll { $0.observer == nil }
    }
    
    func addBoat(_ boat: BoatModel) {
        _boatModels.append(boat)
        cleanObservers()
        for observer in _observers {
            observer.observer?.boatAdded(boat: boat)
        }
    }
    
    func canBuildBoat(type: String) -> Bool {
        var parts = BoatModel.boatData(type: type, with: .part_amount) as! Array<Int>
        for i in 0..<parts.count {
            let currPart = User.BoatPart(boat:type,item: User.MarketItem(rawValue: i)!)
            let tparts = (User.sharedInstance.parts.filter {$0 == currPart})
            let numParts = tparts.count
            let targetParts = parts[i]
            if numParts < targetParts {
                return false
            }
        }
        return true
    }
    
    func boatAtIndex (_ idx: Int) -> BoatModel? {
        if _boatModels.count > idx {
            return _boatModels[idx]
        }
        return nil
    }
    
    var numBoats : Int {
        return _boatModels.count
    }
    
    var marketDate : Date {
        var diff = Date().timeIntervalSince1970 - _marketDate.timeIntervalSince1970
        diff /= User.marketInterval
        return _marketDate + diff.rounded(FloatingPointRoundingRule.down) * User.marketInterval
    }
    
    var jobDate : Date {
        var diff = Date().timeIntervalSince1970 - _jobDate.timeIntervalSince1970
        diff /= User.jobInterval
        _jobDate += diff.rounded(FloatingPointRoundingRule.down) * User.jobInterval
        return _jobDate
    }
    
    var market : Array<BoatPart> {
        let date = marketDate
        if _marketDate != date {
            updateMarket()
            _marketDate = date
        }
        return _market
    }
    
    func removeBoat (_ boat: BoatModel) {
        if let town = boat.town {
            town.removeBoat(boat)
        }
        _boatModels.removeAll(where: {$0 === boat})
        cleanObservers()
        for observer in _observers {
            observer.observer?.boatRemoved(boat: boat)
        }
        stats.boatsSold += 1
        statsUpdated()
    }
    
    var boats : Array<BoatModel> {
        return _boatModels
    }
    
    func purchaseBoatWithParts(boat: BoatModel, parts: Array<BoatPart>) {
        for part in parts {
            self.parts.removeAll { $0 === part }
        }
        addBoat(boat)
    }
    
    func purchaseBoatWithMoney(boat: BoatModel, parts: Array<BoatPart>) {
        addMoney(gold: -(BoatModel.boatData(type: boat.type, with: .boat_cost) as! Int), silver: 0)
        for part in parts {
            self._market.removeAll { $0 === part }
        }
        addBoat(boat)
    }
    
    func removePart(part: BoatPart) {
        if let idx = _market.firstIndex(where: {$0 === part}) {
            _market.remove(at: idx)
        }
    }
    
    private init () {
        self._stats = Stats()
        self.gold = 8
        self.silver = 4000
        self.xp = 0
        self.boatSlots = 4
        self.parts = Array<BoatPart>()
        self._market = Array<BoatPart>()
        self._marketDate = Date()
        self._jobDate = Date()
        self._startDate = Date()
        let map = Map.sharedInstance
        _boatModels = Array<BoatModel>()
        self.updateMarket()
        var boat = BoatModel(type: "raft", name: BoatModel.makeName(), town: map.towns[1])
        _boatModels.append(boat)
        boat = BoatModel(type: "raft", name: BoatModel.makeName(), town: map.towns[4])
        _boatModels.append(boat)
        boat = BoatModel(type: "skiff", name: BoatModel.makeName(), town: map.towns[1])
        _boatModels.append(boat)
        map.towns[1].level = 1
        map.towns[4].level = 1
        map.towns[5].level = 1
        //map.towns[9].level = 1
        map.towns[43].level = 1
    }
    
    private func updateMarket () {
        _market.removeAll()
        for key in BoatModel.boatKeys {
            let level = BoatModel.boatData(type: key, with: .level) as! String
            if self.level < User.rankKeys.firstIndex(of: level)! { continue }
            for i : Int in 0..<5 {
                let parts = BoatModel.boatData(type: key, with: .part_amount) as! Array<Int>
                if Int.random(in: 0...1) == 0 {
                    if i < 4 {
                        let num_parts = parts[i]
                        if num_parts == 0 {
                            continue
                        }
                    }
                    let part = BoatPart(boat: key, item: MarketItem(rawValue: i)!)
                    _market.append(part)
                }
            }
        }
    }
}


