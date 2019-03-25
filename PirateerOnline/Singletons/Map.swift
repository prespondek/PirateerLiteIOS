//
//  Map.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 5/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class Map : Codable {
    let graph = Graph<WorldNode>()
    var towns : Array<TownModel>
    private static var _map : Map?
    
    
    static var JSONPath : URL {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path += "/map.json"
        return URL(fileURLWithPath: path)
    }
    
    static var sharedInstance : Map {
        
        if let map = _map {
            return map
        } else {
            do {
                _map = try JSONDecoder().decode(Map.self, from: Data(contentsOf: Map.JSONPath))
            } catch {
                _map = Map()
            }
            return _map!
        }
    }
    
    enum CodingKeys: String, CodingKey
    {
        case towns
    }
    
    func townPosition ( town: TownModel ) -> CGPoint {
        var pos : CGPoint?
        for vert in graph.vertices {
            if town === vert.data {
                pos = vert.position
                break
            }
        }
        assert( pos != nil )
        return pos!
    }
    
    func getRoute(start: TownModel, end: TownModel) -> Array<Edge<WorldNode>> {
        var source : Vertex<WorldNode>? = nil
        var destination : Vertex<WorldNode>? = nil
        Map.sharedInstance.graph.vertices.forEach { if $0.data === start { source = $0 }}
        Map.sharedInstance.graph.vertices.forEach { if $0.data === end { destination = $0 }}
        let path = Map.sharedInstance.graph.getRoute(algorithm: .Djikstra, start: source!, end: destination!)
        return path
    }
    
    func mergeRoutes(source: Vertex<WorldNode>,
                     paths: Array<Array<Edge<WorldNode>>>) -> Array<Array<Edge<WorldNode>>> {
        
        func splitPath ( vert: Vertex<WorldNode>,
                         path: inout Set<Edge<WorldNode>>,
                         extra: Edge<WorldNode>? = nil ) -> Array<Array<Edge<WorldNode>>>
        {
            var start = vert
            var parts = Array<Array<Edge<WorldNode>>>()
            var stem = Array<Edge<WorldNode>>()
            if (extra != nil) {
                stem.append(extra!)
            }
            while !path.isEmpty {
                let joining = start.outEdges.intersection(path)
                if joining.count == 0 {
                    break
                }
                if joining.count == 1 {
                    path.remove(joining.first!)
                    stem.append(joining.first!)
                    start = joining.first!.next
                    continue
                } else {
                    for join in joining {
                        path.remove(join)
                        parts.append(contentsOf: splitPath(vert: join.next, path: &path, extra: join))
                    }
                }
            }
            if stem.count > 0 {
                parts.append(stem)
            }
            return parts
        }
        if paths.count == 1 {
            return paths
        }
        
        var routes = Set<Edge<WorldNode>>()
        for path in paths {
            for vert in path {
                routes.insert(vert)
            }
        }
        return splitPath(vert: source, path: &routes)
    }

    private init() {
        self.towns = Array<TownModel>()
        self.setup()
    }
    
    required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.towns = try values.decode(Array<TownModel>.self, forKey: .towns)
        self.setup()
    }
    
    func setup () {
        let config : Dictionary<String, AnyObject>
        do {
            config = try JSONSerialization.load(path: "PirateerAssets/map_model.json") as! Dictionary<String, AnyObject>
        } catch {
            fatalError()
        }
        
        let vertexConfig =  config["Vertices"] as? Array<Array<CGFloat>>
        let edgeConfig =    config["Edges"] as? Array<Array<Int>>
        let townInfo =      config["TownInfo"] as? Array<Array<Any>>
        let townIndices =   config["TownIndex"] as? Array<Int>
        let townCost =      config["TownCost"] as? Array<Int>
        let townUpgrade =   config["TownUpgrade"] as? Array<Array<Int>>
        let jobData =       config["Jobs"] as? Array<Array<String>>
        
        guard vertexConfig != nil &&
            townInfo != nil &&
            townIndices != nil &&
            townIndices?.count == townInfo?.count else {
                fatalError()
        }
        
        for i in 0..<vertexConfig!.count {
            var vert_data = vertexConfig![i]
            graph.vertices.append(Vertex(data: WorldNode(), position: CGPoint(x:vert_data[0], y:vert_data[1])))
        }
        TownModel.setGlobals(townCost:townCost!, townUpgrade:townUpgrade!)
        if towns.count == 0 {
            for i in 0..<townInfo!.count {
                let town = TownModel( data: townInfo![i] )
                self.towns.append(town)
            }
        }
        for i in 0..<towns.count {
            towns[i].setup(data: townInfo![i])
            graph.vertices[townIndices![i]].data = towns[i]
        }

        for i in 0..<edgeConfig!.count {
            for edge in edgeConfig![i] {
                graph.vertices[i].linkVertex(other: graph.vertices[edge])
            }
        }
        JobController.jobData = jobData
    }
}
