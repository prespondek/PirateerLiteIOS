//
//  TownView.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 17/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import SpriteKit

class TownView : SKSpriteNode {
    private var boatCounter : SKLabelNode!
    func setup () {
        boatCounter = SKLabelNode(fontNamed: "Avenir-Black")
        boatCounter.fontSize = 12
        boatCounter.fontColor = UIColor.black
        boatCounter.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        boatCounter.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        addChild(boatCounter)
    }
    func setCounter (num : Int) {
        if num > 0 {
            boatCounter.text = String(min(9,num))
        } else {
            boatCounter.text = ""
        }
    }
    func setState (state: TownController.State, townSize: TownModel.HarbourSize) {
        switch state {
        case .selected:
            switch townSize {
            case .small: texture = SKTexture( imageNamed: "town_c1_selected" )
            case .medium: texture = SKTexture( imageNamed: "town_c2_selected" )
            case .large: texture = SKTexture( imageNamed: "town_c3_selected" )
            }
        case .unselected:
            switch townSize {
            case .small: texture = SKTexture( imageNamed: "town_c1_unselected" )
            case .medium: texture = SKTexture( imageNamed: "town_c2_unselected" )
            case .large: texture = SKTexture( imageNamed: "town_c3_unselected" )
            }
        default:
            switch townSize {
            case .small: texture = SKTexture( imageNamed: "town_c1_disabled" )
            case .medium: texture = SKTexture( imageNamed: "town_c2_disabled" )
            case .large: texture = SKTexture( imageNamed: "town_c3_disabled" )
            }
        }
    }
}
