//
//  BoatController.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 5/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import UIKit

class BoatController {
    private static var _mapController : MapViewController?
    let model : BoatModel
    let view : BoatView
    
    var isSailing : Bool {
        return self.model.town == nil
    }
    
    init( model: BoatModel, view: BoatView ) {
        self.model = model
        self.view = view
        if model.town != nil {
            var source : Vertex<WorldNode>? = nil
            Map.sharedInstance.graph.vertices.forEach { if $0.data === model.town { source = $0 }}
            if source != nil {
                view.sprite.position = source!.position
            }
        }
    }
    
    static func setController (controller: MapViewController) {
        BoatController._mapController = controller
    }

    
    func sail() {
        if let town = model.town {
            for case let job? in model.cargo {
                town.removeJob(job: job)
            }
        }

        for i in 1..<self.model.course.count {
            let path = Map.sharedInstance.getRoute(start: self.model.course[i-1],
                                                   end:   self.model.course[i])
            view.addPath(path: Graph.getRoutePositions(path: path))
            var time = self.model.getSailingTime( distance: view.length )
            if model.departureTime != 0 && model.departureTime + time < Date().timeIntervalSince1970 {
                self.arrived(town: path.last!.next.data as! TownModel, quiet: true)
            } else {
                if model.departureTime != 0 {
                    time -= Date().timeIntervalSince1970 - model.departureTime
                }
                Timer.scheduledTimer(withTimeInterval: time, repeats: false) { (time: Timer) in
                    self.arrived(town: path.last!.next.data as! TownModel)
                }
            }
        }
        // if the the boats town is nil that means it has already departed
        if model.course.count > 0 {
            if self.model.town != nil {
                self.model.sail( distance: view.length )
            } else {
                self.model.setDistance( distance: view.length )
            }
            view.sail( startTime: Date(timeIntervalSince1970: self.model.departureTime ),
                       duration: self.model.courseTime )
        }
    }
    
    private func arrived (town: TownModel, quiet : Bool = false) {
        self.model.arrive(town: town, quiet: quiet)
        if self.model.isMoored {
            BoatController._mapController!.boatArrived(boat: self)
            view.removePaths()
        }
    }
}
