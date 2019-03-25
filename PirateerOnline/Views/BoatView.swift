//
//  BoatView.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 4/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class BoatView : SplinePath
{
    weak var controller : BoatController?
    private var icon : String
    var sprite : SKSpriteNode
    private var duration : TimeInterval
    private var timer : TimeInterval
    
    private let _boatType : String
    var boatType : String {
        get { return _boatType }
    }
    
    init(boatType: String) {
        self.controller = nil
        self.duration = 0
        self.timer = 0
        _boatType = boatType
        self.icon = boatType + "_01"
        let tex = SKTexture(imageNamed: self.icon)
        self.sprite = SKSpriteNode(texture: tex, color: UIColor.white, size: tex.size())
    }
    
    func rotate(p0: CGPoint, p1: CGPoint) {
        let angle = ((p1 - p0).angle + CGFloat.pi) / CGFloat(2.0 * CGFloat.pi / 16)
        var frame = round(angle)
        frame += 1
        if frame > 16 { frame = 1 }
        var texture_name = _boatType + "_"
        if (frame < 10) {
            texture_name += "0"
        }
        texture_name += String(Int(frame))
        if (self.icon != texture_name) {
            self.icon = texture_name
            sprite.texture = SKTexture(imageNamed: self.icon )
        }
    }

    
    func sail( startTime: Date, duration: TimeInterval ) {
        self.duration = duration
        self.timer = Date().timeIntervalSince(startTime)
        rotate(p0:splinePosition( time: 0.0 ),
               p1:splinePosition( time: CGFloat.leastNormalMagnitude) )
        sprite.isHidden = false
        
        smooth(segments: Int(length / 20.0))
        let action = SKAction.customAction(withDuration: duration) { (node:SKNode, dt: CGFloat) in
            let prevTime = CGFloat(self.timer / self.duration)
            let currTime = CGFloat(Date().timeIntervalSince(startTime) / self.duration)
            self.timer = Date().timeIntervalSince(startTime)

            if (currTime > 1) {
                return
            }
            let pos1 = self.splinePosition(time: prevTime)
            let pos2 = self.splinePosition(time: currTime)
            self.rotate(p0: pos1, p1: pos2)
            self.sprite.position = pos2
        }
        self.sprite.run(action, withKey: "sail")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
