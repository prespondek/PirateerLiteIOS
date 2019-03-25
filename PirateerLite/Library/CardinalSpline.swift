//
//  CardinalSpline.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 3/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class CardinalSpline
{
    private struct DistanceTableEntry
    {
        var t : CGFloat
        var distance : CGFloat
    }
    
    let length : CGFloat
    var path : Array<CGPoint>
    
    var tension : CGFloat
    
    init( path : Array<CGPoint>, tension: CGFloat = 0.5 )
    {
        self.path = path
        self.tension = tension
        var dist : CGFloat = 0.0
        if self.path.count != 0 {
            for segment in 1..<self.path.count {
                dist += self.path[segment - 1].distance(self.path[segment])
            }
        }
        self.length = dist
    }
    
    static func lerp(_ a: CGFloat,_ b: CGFloat,_ f: CGFloat) -> CGFloat
    {
        return a + f * (b - a)
    }
    
    static func evaluate(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint, tension: CGFloat, t: CGFloat) -> CGPoint
    {
        let t2 = t * t
        let t3 = t2 * t
        
        let s = (1 - tension) / 2
        
        let b1 = s * ((-t3 + (2 * t2)) - t)                      // s(-t3 + 2 t2 - t)P1
        let b2 = s * (-t3 + t2) + (2 * t3 - 3 * t2 + 1)          // s(-t3 + t2)P2 + (2 t3 - 3 t2 + 1)P2
        let b3 = s * (t3 - 2 * t2 + t) + (-2 * t3 + 3 * t2)      // s(t3 - 2 t2 + t)P3 + (-2 t3 + 3 t2)P3
        let b4 = s * (t3 - t2);                                   // s(t3 - t2)P4
        
        let x = (p0.x*b1 + p1.x*b2 + p2.x*b3 + p3.x*b4)
        let y = (p0.y*b1 + p1.y*b2 + p2.y*b3 + p3.y*b4)
        
        return CGPoint(x:x,y:y)
    }


    // Evaluates a curve with any number of points using the Catmull-Rom method
    func evaluateCurve( time: CGFloat ) -> CGPoint
    {
        var p : Int
        var lt : CGFloat
        let deltaT = 1.0 / CGFloat(path.count - 1)
        
        if ( time == 1 ) {
            p = path.count - 1
            lt = 1
        } else {
            p = Int(time / deltaT)
            lt = (time - deltaT * CGFloat(p)) / deltaT;
        }
        var i0 : Int = p-1
        if p == 0 { i0 = 0 }
        let i1 : Int = p
        let i2 : Int = min(path.count - 1, p+1)
        let i3 : Int = min(path.count - 1, p+2)
        
        // Interpolate
        let pp0 = path[i0]
        let pp1 = path[i1]
        let pp2 = path[i2]
        let pp3 = path[i3]
        
        return CardinalSpline.evaluate(p0: pp0, p1: pp1, p2: pp2, p3: pp3, tension: tension, t: lt)
        
    }
    
    private func createDistanceTable( table: inout Array<DistanceTableEntry> )
    {
        let numPointsMin1 = path.count - 1;
        
        var distSoFar = CGFloat(0.0)
        
        let start = DistanceTableEntry(t:0.0,distance:0.0)
        table.append(start)
        for i in 1..<path.count {
            let dist = path[i-1].distance(path[i])
            distSoFar += dist
            let curr = DistanceTableEntry(t: CGFloat(i) / CGFloat(numPointsMin1), distance: distSoFar)
            table.append( curr )
        }
    }
    
    func getNonUniform( segments: Int )
    {
        var array = Array<CGPoint>()
        let numPointsDesiredMin1 = segments-1
        for i in 0..<segments {
            let t = CGFloat(i) / CGFloat(numPointsDesiredMin1)
            array.append(evaluateCurve(time: t))
        }
        path = array
    }
    
    func getUniform( segments: Int )
    {
        var array = Array<CGPoint>()
        var distTable = Array<DistanceTableEntry>()
        createDistanceTable( table: &distTable )
        let numPointsDesiredMin1 = segments-1
        let totalLength = distTable[path.count-1].distance;
        
        for i in 0 ..< segments {
            let distT = CGFloat(i) / CGFloat( numPointsDesiredMin1 )
            let distance = distT * totalLength;
            
            let t = timeValueFromDist( dist: distance, table: &distTable )
            array.append(evaluateCurve( time: t ))
        }
        path = array
    }
        
    private func timeValueFromDist( dist: CGFloat, table: inout Array<DistanceTableEntry> ) -> CGFloat
    {
        for i in stride(from: path.count - 2, to: -1, by: -1) {
            let entry = table[i];
            if dist > entry.distance {
                if(i == self.path.count-1) {
                    return 1.0
                } else {
                    let nextEntry = table[i+1];
                    let lerpT = (dist - entry.distance) / (nextEntry.distance - entry.distance)
                    let t = CardinalSpline.lerp(entry.t, nextEntry.t, lerpT);
                    
                    return t;
                }
            }
        }
        return 0.0;
    }

}
