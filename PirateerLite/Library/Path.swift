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
    
    func splinePosition (time: CGFloat) -> CGPoint {
        var offset : CGFloat = 0.0
        var index : Int = 0
        for idx in 0..<_lengths.count {
            if _lengths[idx] > time {
                index = idx
                break
            } else {
                offset += _lengths[idx]
            }
        }
        return _path[index].evaluateCurve(time: time - offset)
    }
}
