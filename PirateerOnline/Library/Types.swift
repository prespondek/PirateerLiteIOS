//
//  Types.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 31/1/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit
import simd

enum PirateerError: Error {
    case FileNotFound( String )
}

extension double2 {
    init (_ point: CGPoint) {
        self.init(x: Double(point.x), y: Double(point.y))
    }
}

extension CGPoint {
    static func +=(_ left: inout CGPoint,_ right: CGSize) {
        left.x += right.width
        left.y += right.height
    }
    static func +=(_ left: inout CGPoint,_ right: CGPoint) {
        left.x += right.x
        left.y += right.y
    }
    static func -=(_ left: inout CGPoint,_ right: CGPoint) {
        left.x -= right.x
        left.y -= right.y
    }
    static func +(_ left: CGPoint,_ right: CGSize) -> CGPoint {
        return CGPoint(x: left.x + right.width, y: left.y + right.height )
    }
    static func -(_ left: CGPoint,_ right: CGSize) -> CGPoint {
        return CGPoint(x: left.x - right.width, y: left.y - right.height )
    }
    static func -(_ left: CGPoint,_ right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    func lenght () -> CGFloat {
        return sqrt( x*x + y*y );
    }
    func distance (_ other: CGPoint) -> CGFloat {
        return (self - other).lenght()
    }
    var angle : CGFloat {
        get {
            return atan2(y, x);
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension CGSize {
    static func *=(_ left: inout CGSize,_ right: Int) {
        left.width *= CGFloat(right)
        left.height *= CGFloat(right)
    }
    static func /(_ left: CGSize,_ right: Int) -> CGSize {
        return CGSize(width: left.width * CGFloat(right),
                      height: left.height * CGFloat(right) )
    }
    static func *(_ left: CGSize,_ right: CGFloat) -> CGSize {
        return CGSize(width: left.width * right,
                      height: left.height * right )
    }
}

