//
//  GraphExtensions.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 9/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

extension Graph {
    static func getRoutePositions ( path: Array<Edge<T>> ) -> Array<CGPoint>
    {
        var points = Array<CGPoint>()
        points.append( path[0].source.position )
        points.append(contentsOf: path.map { (segment: Edge<T>) -> CGPoint in
            return segment.next.position
        })
        return points
    }
}
