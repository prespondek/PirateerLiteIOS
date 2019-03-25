//
//  TownController.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 2/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import SpriteKit

class TownController {
    private static weak var _controller : MapViewController?
    
    enum State {
        case selected, unselected, disabled, blocked
    }
    
    var model : TownModel
    var button : UIButton
    var view : TownView
    private var _state : State
    var state : State {
        get {
            return _state
        }
        set (state) {
            var new_state = state
            if (new_state == .selected || new_state == .unselected) && model.level == 0 {
                new_state = .disabled
            }
            self._state = new_state
            view.setState(state: new_state, townSize: model.harbour)
        }
    }
    
    static func setController ( controller: MapViewController ) {
        TownController._controller = controller
    }
    
    init(town: TownModel, button: UIButton, view: TownView ) {
        self.model =    town
        self.button =   button
        self.view =   view
        self._state =    .disabled
        button.addTarget(self, action: #selector(TownController.buttonPressed), for: UIControl.Event.touchUpInside)
        updateView()
    }
    
    func updateView () {
        view.setCounter(num: model.boats.count)
    }
    func reset() {
        if model.level > 0 {
            state = .unselected
        }
    }
    
    @IBAction func buttonPressed(sender: UIButton, forEvent event: UIEvent) {
        
        TownController._controller?.townSelected(town: self)
        //facade.texture = SKTexture( imageNamed: "town_marker_selected" )
    
    }
}
