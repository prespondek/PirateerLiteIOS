//
//  Debug.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 8/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

extension MapViewController {
    func debugGraph () {
        var counter = 0
        for vert in Map.sharedInstance.graph.vertices {
            let town = vert.data as? TownModel
            if town == nil { continue }
            var idx = 0
            for i in 0..<Map.sharedInstance.towns.count {
                if (Map.sharedInstance.towns[i] === town) {
                    break
                }
                idx += 1
            }
            let node_label = SKLabelNode(text: String(idx))
            node_label.color = UIColor.red
            node_label.position = CGPoint(x:vert.position.x,
                                          y:vert.position.y)
            node_label.fontSize = 16
            node_label.zPosition = 4
            scene!.addChild(node_label)
            counter += 1
        }
    }

    func debugRoute ( route: Array<Vertex<WorldNode>> ) {
        for vert in Map.sharedInstance.graph.vertices {
            if vert.score == CGFloat.greatestFiniteMagnitude { continue }
            let score = SKLabelNode(text: String(Int(vert.score)))
            score.position = vert.position
            score.fontSize = 12
            scene?.addChild(score)
        }
        
        for i in 0..<route.count - 1 {
            let vert = route[i]
            for edge in vert.outEdges {
                let line = SKShapeNode( )
                let path = CGMutablePath( )
                var color = UIColor.yellow
                if route[i+1] === edge.next {
                    color = UIColor.red
                }
                if i > 0 && route[i-1] === edge.next { continue }
                path.move(to: CGPoint(x: vert.position.x, y: vert.position.y))
                path.addLine(to: CGPoint(x: edge.next.position.x, y: edge.next.position.y))
                line.path = path
                line.strokeColor = color
                scene?.addChild(line)
            }
        }
    }
}
