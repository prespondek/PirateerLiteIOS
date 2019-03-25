//
//  Graph.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 31/1/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class Vertex<T> : Hashable
{
    static func == (lhs: Vertex<T>, rhs: Vertex<T>) -> Bool {
        return lhs.position == rhs.position
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(position.x)
        hasher.combine(position.y)
    }
    
    var data :      T
    var position =  CGPoint(x:0,y:0)
    var score =     CGFloat.greatestFiniteMagnitude
    var visited =   false
    var outEdges =  Set<Edge<T>>()
    var inEdges =   Set<Edge<T>>()
    
    
    init ( data: T, position: CGPoint ) {
        self.data = data
        self.position = position
    }
    
    func getEdge (other: Vertex<T>) -> Edge<T>? {
        for edge in self.outEdges {
            if edge.next === other {
                return edge
            }
        }
        return nil
    }
    
    static func compareRange (_ left: Vertex<T>,_ right: Vertex<T>) -> Bool {
        return (left.score < right.score)
    }
    
    func linkVertex(other: Vertex<T>)
    {
        let edge = Edge(source: self,  target: other)
        edge.weight = self.position.distance(other.position);
        self.outEdges.insert(edge)
        other.inEdges.insert(edge)
    }
}

class Edge<T> : Hashable
{
    let next :      Vertex<T>
    let source :    Vertex<T>
    var weight :    CGFloat = 0
    var range :     CGFloat = 0
    
    init(source: Vertex<T>, target: Vertex<T>) {
        self.next = target
        self.source = source
    }
    
    static func == (lhs: Edge<T>, rhs: Edge<T>) -> Bool {
        return  lhs.next.position == rhs.next.position &&
                lhs.source.position == rhs.source.position
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(source.position.x)
        hasher.combine(source.position.y)
        hasher.combine(next.position.y)
        hasher.combine(next.position.y)
    }
    
}

class Graph<T>
{
    
    var vertices = Array<Vertex<T>>()
    
    enum Algorithm {
        case Djikstra
    }

    required internal init () {}
    
    public convenience init             (vertices: Array<Vertex<T>>) {
        self.init()
        self.vertices = vertices
    }
    
    func getRoute(algorithm: Algorithm, start: Vertex<T>, end: Vertex<T>) -> Array<Edge<T>>
    {
        for vertex in vertices {
            vertex.score = CGFloat.greatestFiniteMagnitude
            vertex.visited = false
        }
        
        switch algorithm {
        case .Djikstra:
            fallthrough
        default:
            primeGraphDjikstra( start: start, end: end )
            return getRouteDjikstra( start: start, end: end )
        }
    }
    
    static func getRouteDistance(route: Array<Edge<T>> ) -> CGFloat
    {
        var distance : CGFloat = 0.0
        route.forEach {distance += $0.weight}
        return distance
    }
    
    private func getRouteDjikstra( start: Vertex<T>, end: Vertex<T> ) -> Array<Edge<T>>
    {
        var route = Array<Edge<T>>()
        var node = end;
        
        while (node !== start) {
            var link : Edge<T>?
            for edge in node.inEdges {
                if (node.score > edge.source.score) {
                    node = edge.source
                    link = edge
                }
            }
            route.append(link!);
        }
        route.reverse();
        return route
    }
    
    private func primeGraphDjikstra ( start: Vertex<T>, end: Vertex<T>)
    {
        var queue = PriorityQueue<Vertex<T>>(sort: Vertex<T>.compareRange)
        start.score = 0
        queue.enqueue(element: start)
        while !queue.isEmpty {
            let top = queue.peek()!
            if top === end { break }
            _ = queue.dequeue()
            if (top.visited == true) { continue }
            //print("Visiting " + String(top.id) + " with score of " + String(Int(top.score)));
            for edge in top.outEdges {
                if edge.next.visited == false {
                    if (edge.next.score > (top.score + edge.weight)) {
                        edge.next.score = top.score + edge.weight
                        //print("Point " + String(edge.next.id) + " set score to: " + String(Int(edge.next.score)))
                    }
                    queue.enqueue(element: edge.next)
                    top.visited = true;
                }
            }
        }
    }

}


