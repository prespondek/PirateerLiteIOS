//
//  MapScene.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 28/1/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import SpriteKit
import simd

class MapScene: SKScene {
    
    //var mapModel : MapModel?
    var padding : CGSize
    private var _root : SKNode
    private var _plotNode : SKNode
    private var _jobNode : SKNode
    private var _messageNode : SKNode
    private var _selectionCircle :  SKShapeNode?
    
    required init?(coder aDecoder: NSCoder) {
        self._root = SKNode()
        self._plotNode = SKNode()
        self._jobNode = SKNode()
        self._messageNode = SKNode()
        self.padding = CGSize(width:0,height:0)
        super.init(coder: aDecoder)
        super.addChild(_root)
        _plotNode.zPosition = 1
        addChild(_plotNode)
        _jobNode.zPosition = 2
        addChild(_jobNode)
    }
    
    override func addChild(_ node: SKNode) {
        _root.addChild(node)
    }
    
    func clearPlot() {
        _plotNode.removeAllChildren()
    }
    func clearJobMarkers() {
        _jobNode.removeAllChildren()
    }
    
    /// Set map view using data. Typically from a json file.
    /// - Parameters:
    ///   - data: A dictionary with String, Value pairs
    func setup ( data: Dictionary<String,AnyObject> ) {
        setPadding      ( data: data["Padding"] as! Array<Int> )
        setDimensions   ( data: data["Dimensions"] as! Array<Int> )
        makeBackground  ( data: data["TileIndex"] as! Array<String>,
                         files: data["TileFile"] as! Array<String> )
        makeAnimations  ( data: data )
        makeFlags       ( data: data )
    }
    
    /// Set offset of root node
    /// - Parameters:
    ///   - position: value to offset node
    func setOffset(position: CGPoint) {
        _root.position = position
    }
    func showMoney(town: TownModel, gold: Int, silver: Int) {
        let pos = Map.sharedInstance.townPosition(town: town)
        var arr = [Any]()
        
        if gold > 0 {
            arr.append(contentsOf: ["gold_piece", String(gold),
                                    UIColor(red: 1.0, green: 0.9, blue: 0, alpha: 1.0)])
        }
        if silver > 0 {
            arr.append(contentsOf: ["silver_piece", String(silver),
                                    UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)])
        }
        var sarr = Array<SKNode>()
        for i in stride(from: 0, to: arr.count, by: 3) {
            let image = SKSpriteNode(imageNamed: arr[i] as! String)
            image.anchorPoint = CGPoint(x:0,y:0)
            let label = SKLabelNode(fontNamed: "Avenir-Heavy")
            label.fontSize = 14
            label.text = "+" + String(arr[i+1] as! String)
            let scale = label.frame.height / image.frame.height * 1.5
            image.setScale(scale)
            var pad : CGFloat = 0
            if i > 0 {
                pad += (sarr[i-3] as! SKSpriteNode).frame.size.width
                pad += (sarr[i-2] as! SKLabelNode).frame.size.width
            }
            label.fontColor = arr[i+2] as! UIColor

            image.position = CGPoint(x:pad, y:0)
            label.position = CGPoint(x:image.position.x + image.frame.size.width + label.frame.size.width * 0.5,
                                     y:(image.frame.size.height - label.frame.size.height) * 0.5)
            sarr.append(contentsOf: [image,label])
        }
        var messageSize = CGSize(width:0,height:0)
        sarr.forEach({
            messageSize.width += $0.frame.width;
            messageSize.height = max(messageSize.height, $0.frame.height)
        })
        let message = SKNode()
        let effect2 = SKEffectNode()
        let effect1 = SKEffectNode()
        message.addChild(effect1)
        sarr.forEach({
            effect2.addChild($0.copy() as! SKNode)
            message.addChild($0)
        })
        effect2.blendMode = .alpha
        effect2.filter = CIFilter( name: "CIBoxBlur",
                                 parameters: ["inputRadius": 5])
        effect1.addChild(effect2)
        effect1.blendMode = .alpha
        effect1.filter = CIFilter( name: "CIColorClamp",
                                   parameters: ["inputMinComponents": CIVector(x:0, y:0, z:0, w: 0),
                                                "inputMaxComponents": CIVector(x:0, y:0, z:0, w: 1)])
        message.position = pos - messageSize * CGFloat(0.5)
        message.position.y += 16
        message.run(SKAction.move(by: CGVector(dx: 0, dy: 32), duration: 1.0))
        message.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                       SKAction.fadeOut(withDuration: 1.0),
                                       SKAction.removeFromParent()]))
        scene!.addChild(message)
    }
    
    func setDimensions(data: Array<Int> ) {
        self.size = CGSize(width: CGFloat (data[0]) + padding.width * 2,
                           height: CGFloat (data[1]) - padding.height * 2)
    }
    
    func setPadding(data: Array<Int> ) {
        self.padding = CGSize(width: data[0], height: data[1])
        _root.position = CGPoint(x:padding.width, y:padding.height)
    }

    func makeBackground (data: Array<String>, files: Array<String>) {
        // the map is represented by an array of strings. Each character represents an index that is
        // associated with a filename
        for y in 1...data.count {
            let row = data[ y-1 ].utf8
            var x = 0
            for char in row {
                x += 1
                let index = Int(String(char))! - 48
                let tile = SKSpriteNode(texture: SKTexture(imageNamed: files[index]))
                tile.anchorPoint = CGPoint(x:0,y:1)
                tile.position = CGPoint (x: tile.size.width * CGFloat(x - 1),
                                         y: -tile.size.height * CGFloat(y - 1))

                addChild(tile)
            }
        }
    }
    
    func makeAnimations (data: Dictionary<String,AnyObject>) {
        let anim = data["Animations"] as! Array<Array<Any>>
        for atom in anim {
            let name = atom[0] as! String
            let framenames = data[name] as! Array<String>
            let sprite = SKSpriteNode.makeAnimation( frames: framenames,
                                                   interval: atom[2] as! Double,
                                                    withKey: atom[0] as! String,
                                                  randomize: true )
            // only negative size seems to work, negative scale arent even visible
            sprite.size = CGSize(  width:atom[5] as! CGFloat * sprite.size.width,
                                 height: atom[6] as! CGFloat * sprite.size.height)
            sprite.position = CGPoint(x: atom[3] as! CGFloat,
                                      y: atom[4] as! CGFloat)
            addChild(sprite)
        }
    }
    
    func makeFlags (data: Dictionary<String,AnyObject>) {
        let flags = data["Flags"] as! Array<Array<Double>>
        
        var idx = 0
        for vert in (Map.sharedInstance.graph.vertices) {
            let town = vert.data as? TownModel
            if town == nil || town!.allegiance == .none { continue }
            var flag = flags[idx]
            var framenames = data["flags"] as! Array<String>
            framenames = framenames.map({ town!.allegiance.rawValue + $0 })
            let sprite = SKSpriteNode.makeAnimation( frames: framenames,
                                                   interval: 0.1,
                                                    withKey: (town?.name)!,
                                                  randomize: true )
            sprite.position = CGPoint( x: CGFloat(flag[0]) + 8,
                                       y: CGFloat(flag[1]) + 32)
            addChild(sprite)
            
            let flag_pole = SKSpriteNode(imageNamed: "flag_pole.png")
            flag_pole.position = CGPoint( x: CGFloat(flag[0]),
                                          y: CGFloat(flag[1]) + 16 )
            addChild(flag_pole)
            idx+=1
        }
    }

    
    func plotRouteToTown( start: TownController, end: TownController, image: String )
    {
        let path = Map.sharedInstance.getRoute(start: start.model, end: end.model)
        showCourseTrail ( path: path, image: image )
    }
    
    func plotJobMarkers ( boat: BoatModel ) {
        _jobNode.removeAllChildren()
        var towns = Set<TownModel>()
        boat.cargo.forEach({if let town = $0 {towns.insert(town.destination)}})
        for town in towns {
            let pos = Map.sharedInstance.townPosition(town: town)
            let marker = SKSpriteNode( imageNamed: "job_marker" )
            marker.position = pos
            marker.zPosition = 2
            marker.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            marker.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: 0.0, y: 8.0, duration: 0.5),
                SKAction.moveBy(x: 0.0, y: -8.0, duration: 0.5)])))
            _jobNode.addChild(marker)
        }
    }
    
    func plotRoutesForTown ( town: TownModel, paths: Array<Array<Edge<WorldNode>>>, distance: CGFloat )
    {
        _selectionCircle?.removeFromParent( )
        let shape = SKShapeNode( circleOfRadius: distance )
        let scene_pos = Map.sharedInstance.townPosition( town: town )
        shape.run( SKAction.scale( to: 1.0, duration: 1.0 ) )
        shape.position = scene_pos
        shape.setScale(0)
        shape.fillColor = UIColor( red: 1, green: 1, blue: 1, alpha: 0.2 )
        if paths.count > 0 {
            let parts = Map.sharedInstance.mergeRoutes(source: paths[0].first!.source, paths: paths)
            for part in parts {
                showCourseTrail(path: part, image: "nav_plot")
            }
        }
        _plotNode.addChild( shape )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _root.position = CGPoint(x:-scrollView.contentOffset.x, y:scrollView.contentOffset.y) + padding
    }
    
    func showCourseTrail ( path: Array<Edge<WorldNode>>, image: String )
    {
        let spline = CardinalSpline(path: Graph.getRoutePositions(path: path))
        spline.getUniform(segments: Int(max(spline.length * 0.06,4)))
        spline.getUniform(segments: Int(max(spline.length * 0.06,4)))
        for point in 0..<spline.path.count {
            let plotSprite = SKSpriteNode( imageNamed: image )
            plotSprite.position = spline.path[point]
            _plotNode.addChild(plotSprite)
            if point == 0 {
                plotSprite.isHidden = true
            }
        }
    }
    
    func plotCourseForBoat ( boat: BoatController ) {
        let percent = boat.model.percentCourseComplete
        let time = boat.model.remainingTime
        let size = _plotNode.children.count
        for i in 0..<size {
            let rtime = CGFloat(size) * percent
            if i <= Int(rtime) {
                _plotNode.children[i].run(SKAction.removeFromParent())
            } else {
                let action = SKAction.sequence([SKAction.wait(forDuration: (time /
                    (TimeInterval(size) - TimeInterval(rtime))) *
                    (TimeInterval(i) - TimeInterval(rtime))),
                                                SKAction.scale(to: 0, duration: 0.5), SKAction.removeFromParent()])
                _plotNode.children[i].run(action)
            }
        }
    }

}

class MapSKView: SKView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
