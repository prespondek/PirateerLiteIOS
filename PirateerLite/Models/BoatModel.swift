//
//  BoatModel.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 31/1/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class BoatModel : Codable {
    enum BoatIndex : Int {
        case
        harbourType = 0, distance, speed, frames, min_parts, max_parts,
        min_crew, max_crew, hold_width, hold_height, hold_size, parts,
        holdBG, title, image, level, part_amount,part_cost, upgrade_cost,
        boat_cost, description
    }
    static func boatData(type: String, with index: BoatIndex) -> Any {
        return boatValues[type]![index.rawValue]
    }
    
    static private let boatData : Dictionary<String, Any> = {
        do {
            return try JSONSerialization.load(path: "PirateerAssets/boat_model.json") as! Dictionary<String, AnyObject>
        } catch {
            fatalError()
        }
    }()
    static var boatKeys : Array<String> {
        return boatData["BoatTypes"] as! Array<String>
    }
    static var boatValues : Dictionary<String, Array<Any>> {
        return boatData["BoatData"] as! Dictionary<String, Array<Any>>
    }
    static var boatParts : Array<Array<String>> {
        return boatData["BoatParts"] as! Array<Array<String>>
    }
    static private let boatNames : Array<Array<Any>> = {
        do {
            return try JSONSerialization.load(path: "PirateerAssets/boat_names.json") as! Array<Array<Any>>
        } catch {
            fatalError()
        }
    }()
    
    let type : String
    private var _departureTime : TimeInterval
    private var _courseTime : TimeInterval
    private var _cargo : Array<JobModel?>
    private var _name : String = ""
    private var _speed : CGFloat = 0.0
    private var _town : TownModel?
    private var _course : Array<TownModel>
    private var _cargoSize : Int = 0
    private var _stats : BoatStats
    
    enum CodingKeys: String, CodingKey
    {
        case _name
        case type
        case _departureTime
        case _courseTime
        case townIndex
        case courseIndices
        case _cargo
        case _stats
    }
    var stats : BoatStats {
        return _stats
    }
    var name : String {
        get { return _name }
    }
    var cargo : Array<JobModel?> {
        get { return _cargo }
    }
    var cargoSize : Int {
        return _cargoSize
    }
    var arrivalTime : TimeInterval {
        return _departureTime + _courseTime
    }
    var remainingTime : TimeInterval {
        return arrivalTime - Date().timeIntervalSince1970
    }
    var departureTime : TimeInterval {
        return _departureTime
    }
    var courseTime : TimeInterval {
        return _courseTime
    }
    var courseDistance : Double {
        return Double(_courseTime) * Double(_speed)
    }
    var sailTime : TimeInterval {
        return Date().timeIntervalSince(Date(timeIntervalSince1970: _departureTime))
    }
    var town : TownModel? {
        return _town
    }
    var course : Array<TownModel> {
        return _course
    }
    var endurance : CGFloat {
        return BoatModel.boatValues[self.type]![1] as! CGFloat
    }
    var percentCourseComplete : CGFloat {
        return CGFloat(sailTime  / _courseTime)
    }
    var value : Int {
        return BoatModel.boatValues[self.type]![BoatModel.BoatIndex.boat_cost.rawValue] as! Int
    }
    var title : String {
        return BoatModel.boatValues[self.type]![BoatModel.BoatIndex.title.rawValue] as! String
    }
    func plotCourse ( town: TownModel ) {
        _course.append(town)
    }
    
    func plotCourse ( towns: Array<TownModel> ) {
        _course = towns
    }
    
    func setCargo (jobs: Array<JobModel?>) {
        if jobs.count <= _cargoSize {
            _cargo = jobs
        } else {
            fatalError("JobModel.setCargo: index out of range")
        }
    }
    
    convenience init( type: String, name: String, town: TownModel ) {
        self.init(type: type, name: name)
        self._town = town
        self._town!.addBoat(self)
    }
    
    required init( type: String, name: String) {
        self._departureTime = 0
        self._courseTime = 0
        self._name = name
        self.type = type
        self._cargo = Array<JobModel>()
        self._course = Array<TownModel>()
        var data = BoatModel.boatValues[self.type]
        self._speed = data![2] as! CGFloat
        self._cargoSize = data![10] as! Int
        self._stats = BoatStats()
    }
    
    func sail ( distance: CGFloat ) {
        self._departureTime = Date().timeIntervalSince1970
        setDistance(distance: distance)
        self._stats.totalDistance += Double(distance)
        self._town?.boatDeparted(boat: self)
        self._town = nil
    }
    
    func arrive ( town: TownModel, quiet: Bool = false ) {
        var gold = 0.0
        var silver = 0.0
        var counter = 0
        _cargo.removeAll(where: {
            if let job = $0 {
                if town === job.destination {
                    counter += 1
                    if job.isGold {
                        gold += job.value
                    } else {
                        silver += job.value
                    }
                    town.jobDelivered(job)
                    return true
                }
            }
            return false
        })
        var multipler = 1.0
        if counter == cargoSize {
            multipler = 1.25
        }
        if quiet {
            User.sharedInstance.gold += Int(gold * multipler)
            User.sharedInstance.silver += Int(silver * multipler)
        } else {
            User.sharedInstance.addMoney(gold: Int(gold * multipler), silver: Int(silver * multipler))
        }
        self._stats.totalGold += Int(gold)
        self._stats.totalSilver += Int(silver)
        User.sharedInstance.xp += Int(silver * multipler)
        NotificationCenter.default.post(name: NSNotification.Name.jobDelivered, object: self,
            userInfo: ["Town" : town, "Silver": Int(silver), "Gold": Int(gold), "Boat": self, "Quiet": quiet])
        
        if ( town === _course.last ) {
            self._stats.totalDistance = courseDistance
            self._stats.totalVoyages += 1
            self._town = _course.last
            self._town!.boatArrived(boat: self)
            User.sharedInstance.boatArrived(self)
            self._departureTime = 0
            self._courseTime = 0
            _course.removeAll()
            AudioManager.sharedInstance.playSound(sound: "boat_arrive")
            NotificationCenter.default.post(name: NSNotification.Name.boatArrived, object: self, userInfo: ["Boat": self, "Town" : town])
            if quiet == false {
                User.sharedInstance.save()
            }
        }
    }
    
    var destination : TownModel? {
        return course.last
    }
    
    var isMoored : Bool {
        get { return self._town != nil }
    }
    
    func setDistance (distance: CGFloat ) {
        self._courseTime = getSailingTime(distance: distance)
    }
    
    func getSailingTime ( distance: CGFloat ) -> TimeInterval {
        return TimeInterval( distance / self._speed )
    }
    
    // generates a random boat name using various methods
    static public func makeName( ) -> String {
        var name = String()
        let type = Int.random(in: 1...6)
        
        for frag in boatNames {
            let name_frag = frag.first as! String
            let frag_values = frag.last as! Array<String>
            let idx = Int.random(in: 0..<frag_values.count)
            if name_frag == "ProNoun" && (type == 5 || type == 2 || type == 3) {
                name += frag_values[idx] + " "
            }
            else if name_frag == "Owner" && (type == 4 || type == 2 || type == 6) {
                name += frag_values[idx]
                if (type == 4) {
                    name += "'s"
                }
                name += " "

            }
            else if name_frag == "Verb" && type == 1 {
                name += frag_values[idx] + " "
            }
            else if name_frag == "Subject" && (type == 1 || type == 3 || type == 4 || type == 5) {
                name += frag_values[idx] + " "
            }
            else if name_frag == "Location" && type == 6 {
                name += frag_values[idx] + " "
            }
        }
        return name
    }
    
    required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(String.self, forKey: .type)
        _name = try values.decode(String.self, forKey: ._name)
        var data = BoatModel.boatValues[self.type]
        self._speed = data![2] as! CGFloat
        self._cargoSize = data![10] as! Int
        self._courseTime = try values.decode(TimeInterval.self, forKey: ._courseTime)
        self._departureTime = try values.decode(TimeInterval.self, forKey: ._departureTime)
        self._stats = try values.decode(BoatStats.self, forKey: ._stats)
        if let idx = try values.decode(Int?.self, forKey: .townIndex) {
            _town = Map.sharedInstance.towns[idx]
        }
        _course = Array<TownModel>()
        for idx in try values.decode(Array<Int>.self, forKey: .courseIndices) {
            _course.append(Map.sharedInstance.towns[idx])
        }
        _cargo = try values.decode(Array<JobModel?>.self, forKey: ._cargo)
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(_name, forKey: ._name)
        try container.encode(_departureTime, forKey: ._departureTime)
        try container.encode(_courseTime, forKey: ._courseTime)
        try container.encode(_cargo, forKey: ._cargo)
        try container.encode(_stats, forKey: ._stats)
        try container.encode(Map.sharedInstance.towns.firstIndex(where: {_town === $0}) , forKey: .townIndex)
        var townIndices = Array<Int>()
        _course.forEach { (model: TownModel) in
            townIndices.append(Map.sharedInstance.towns.firstIndex(where: {$0 === model})!)
        }
        try container.encode(townIndices, forKey: .courseIndices)
    }
}

struct BoatStats : Codable {
    var totalDistance : Double
    var totalVoyages : Int
    var totalSilver : Int
    var totalGold : Int
    var datePurchased : Date
    
    var SPM : Double {
         return max(0,Double(totalSilver) / totalDistance)
    }

    init () {
        self.totalSilver = 0
        self.totalGold = 0
        self.totalDistance = 0
        self.datePurchased = Date()
        self.totalVoyages = 0
    }
}
