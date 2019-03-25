//
//  Path.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 4/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class SplinePath
{
    private var _path = Array<CardinalSpline>()
    private var _lengths = Array<CGFloat>()
    private var _length : CGFloat = 0
    
    var length : CGFloat {
        get {
            return _length
        }
    }
    var lengths : Array<CGFloat> {
        get {
            return _lengths
        }
    }
    var count : Int {
        get {
            return _path.count
        }
    }
    
    init() {
    }
    func pathLength (at index: Int) -> CGFloat {
        return _path[index].length
    }
    
    func addPath (path: Array<CGPoint>) {
        let new_path = CardinalSpline(path: path)
        _path.append(new_path)
        let dist = new_path.length
        _length += dist
        _lengths.removeAll()
        _path.forEach { _lengths.append($0.length / _length) }
    }
    
    func removePaths () {
        _path.removeAll()
        _lengths.removeAll()
        _length = 0
    }
    
    func smooth ( segments: Int ) {
        for length in 0..<_lengths.count {
            _path[length].getUniform(segments: Int(CGFloat(segments) * _lengths[length]))
            _path[length].getUniform(segments: Int(CGFloat(segments) * _lengths[length]))
        }
    }
    
    func splinePosition (time: CGFloat) -> CGPoint {
        var offset : CGFloat = 0.0
        var index : Int = 0
        for idx in 0..<_lengths.count {
            if _lengths[idx] + offset > time {
                index = idx
                break
            }
            offset += _lengths[idx]
        }
        let realtime = (time - offset) * (1/_lengths[index])
        return _path[index].evaluateCurve(time: realtime)
    }
}
