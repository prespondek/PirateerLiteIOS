//
//  SKHelper.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 1/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import SpriteKit

extension SKSpriteNode {
    static public func makeAnimation (frames: Array<String>,
                                      interval: Double,
                                      withKey: String = "",
                                      randomize: Bool = false,
                                      resize: Bool = false,
                                      restore: Bool = true) -> SKSpriteNode {
        // add some variation to animation by spliting frames at a random point and sew back together
        var framenames = frames
        if (randomize) {
            let split = Int.random(in: 0..<frames.count)
            framenames = Array(frames[split...]) + Array (frames[..<split])
        }
        // convert filenames to SKTextures
        var frametextures : [SKTexture] = framenames.map({SKTexture(imageNamed: $0)})
        let sprite = SKSpriteNode(texture: frametextures[0])
        sprite.run(SKAction.repeatForever(
            SKAction.animate(with: frametextures,
                             timePerFrame: TimeInterval(interval),
                             resize: resize,
                             restore: restore)),
                   withKey:withKey)
        return sprite
    }
}

