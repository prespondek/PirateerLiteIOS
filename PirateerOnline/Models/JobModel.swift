//
//  JobModel.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 31/1/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation

class JobModel : Codable {
    var source : TownModel {
        get { return Map.sharedInstance.towns[_sourceIndex] }
        set ( town ) {
            _destinationIndex = Map.sharedInstance.towns.firstIndex(where: {$0 === town})!
            calcValue()
        }
    }
    var destination : TownModel {
        get { return Map.sharedInstance.towns[_destinationIndex] }
        set ( town ){
            _destinationIndex = Map.sharedInstance.towns.firstIndex(where: {$0 === town})!
            calcValue()
        }
    }
    
    enum CodingKeys: String, CodingKey
    {
        case _sourceIndex
        case _destinationIndex
        case type
        case _value = "value"
        case _gold = "gold"
        case multiplier
    }
    var type : String
    private var _value : Double
    private var _gold = false
    private var _sourceIndex : Int
    private var _destinationIndex : Int
    var multiplier : Double

    var value : Double {
        get {
            return _value
        }
    }
    var isGold : Bool {
        get {
            return _gold
        }
    }
    
    private func calcValue () {
        let route = Map.sharedInstance.getRoute(start: source, end: destination)
        _value = Double(Graph.getRouteDistance(route: route))
    }
    
    init (source: TownModel, destination: TownModel) {
        _destinationIndex = Map.sharedInstance.towns.firstIndex(where: {$0 === destination})!
        _sourceIndex = Map.sharedInstance.towns.firstIndex(where: {$0 === source})!
        self.multiplier = 1.0
        self.type = JobController.jobData.randomElement()![0]
        if Int.random(in: 1...10) == 1 {
            _gold = true
        }
        self._value = 0
        self.calcValue()
        if _gold {
            _value *= 0.01
        }
    }
    
    required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(String.self, forKey: .type)
        _sourceIndex = try values.decode(Int.self, forKey: ._sourceIndex)
        _destinationIndex = try values.decode(Int.self, forKey: ._destinationIndex)
        _gold = try values.decode(Bool.self, forKey: ._gold)
        _value = try values.decode(Double.self, forKey: ._value)
        multiplier = try values.decode(Double.self, forKey: ._value)
    }
    
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(_sourceIndex, forKey: ._sourceIndex)
        try container.encode(_destinationIndex, forKey: ._destinationIndex)
        try container.encode(_gold, forKey: ._gold)
        try container.encode(_value, forKey: ._value)
        try container.encode(multiplier, forKey: .multiplier)
    }
}
