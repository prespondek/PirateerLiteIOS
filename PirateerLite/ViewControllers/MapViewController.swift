//
//  ViewController.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 26/1/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import UserNotifications

class MapViewController: UIViewController, UserObserver {
    
    enum Mode {
        case plot, map, track, nontrack, build, buy
    }
    
    @IBOutlet weak var cargoButton:     UIButton!
    @IBOutlet weak var sailButton:      UIButton!
    @IBOutlet weak var cancelButton:    UIButton!
    @IBOutlet weak var skView:          MapSKView!
    @IBOutlet weak var scrollView:      UIScrollView!
    @IBOutlet weak var wallet:          WalletView!
    @IBOutlet weak var toolTip:         UILabel!
    
    
    //private var mapModel :          MapModel?
    private var _boatControllers =  Array<BoatController>()
    private var _townControllers =  Array<TownController>()
    private var _trackBoat =        false
    private var _selectedBoat :     BoatController?
    private var _boatCourse =       Array<TownController>()
    private var _buildType :        String?
    private var _buildParts =       Array<User.BoatPart>()
    private var _selectedTint :     UIColor!
    
    private static var _map :       MapViewController!
    
    var scene : MapScene!
    
    static var instance : MapViewController {
        get {
            return _map
        }
    }
    
    var mode : Mode
    {
        get {
            if _selectedBoat != nil {
                if _selectedBoat!.model.town != nil {
                    return .plot
                } else if _trackBoat == false {
                    return .nontrack
                } else {
                    return .track
                }
            } else if toolTip.isHidden == false {
                if _buildParts.count > 1 {
                    return .build
                } else {
                    return .buy
                }
            } else {
                return .map
            }
        }
    }
    @IBAction func unwindBoatSold(segue:UIStoryboardSegue) {
        reset()
    }
    
    @IBAction func unwindToMap(segue:UIStoryboardSegue) {
        reset()
        toolTip.isHidden = false
        cancelButton.isHidden = false
        if let source = segue.source as? BoatInfoViewController {
            _buildType = source.boatType
            _buildParts = source.parts
        } else if let source = segue.source as? MarketViewController {
            _buildType = source.selectedPart?.boat
            _buildParts = [source.selectedPart!]
        }
        let harborType = TownModel.HarbourSize(rawValue: BoatModel.boatData(type: _buildType!, with: BoatModel.BoatIndex.harbourType) as! String)
        for town in _townControllers {
            if harborType! > town.model.harbour {
                town.state = .blocked
            }
        }
    }

    
    @IBAction func sailButtonPressed(_ sender: Any) {
        scene.clearPlot()
        if let boat = _selectedBoat {
            boat.model.plotCourse(towns: _boatCourse.map{ $0.model })
            let controller = townControllerForModel(model: boat.model.town!)
            boat.sail()
            controller.updateView()
            AudioManager.sharedInstance.playSound(sound:"ship_bell")
            
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications:[UNNotificationRequest]) in
                var pendingnotify = false
                let date = Date(timeIntervalSince1970:boat.model.arrivalTime)
                for notify in notifications {
                    if notify.identifier == "BoatArrival" {
                        let old_trigger = notify.trigger as! UNCalendarNotificationTrigger
                        if old_trigger.nextTriggerDate()! > date {
                            pendingnotify = true
                            break
                        }
                    }
                }
                if pendingnotify == false {
                    let content = UNMutableNotificationContent()
                    content.title = "Voyage complete"
                    content.body = String(format: "All boats are moored at their destination.")
                    content.sound = UNNotificationSound(named: UNNotificationSoundName("ship_bell"))
                    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date ),
                                                                repeats: false)
                    UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "BoatArrival", content: content, trigger: trigger), withCompletionHandler: nil)
                }
            }
            User.sharedInstance.save()
            reset()
        }
    }

    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        if mode == .plot {
            if (_boatCourse.count > 1) {
                var town = _boatCourse.popLast()
                town?.state = .unselected
                town = _boatCourse.popLast()
                town?.state = .unselected
                townSelected( town: town! )
            }  else {
                let town = _boatCourse.first
                town?.state = .unselected
                reset()
            }
        } else if mode == .build ||  mode == .buy {
            toolTip.isHidden = true
            cancelButton.isHidden = true
            tabBarController?.selectedIndex = 2
            tabBar(enabled: true)
        }
    }
    @IBAction func applicationWillEnterBackground () {
       
    }
    
    @IBAction func applicationWillEnterForeground () {
        switch mode {
            case .track:
                startTracking( boat: _selectedBoat! )
                fallthrough
            case .nontrack:
                scene.clearPlot()
                plotCourseForBoat( boat: _selectedBoat! )
                default:
                    return
        }
    }
    
    func reset() {
        toolTip.isHidden = true
        for town in _townControllers {
            town.reset()
        }
        cargoButton.isHidden = true
        cancelButton.isHidden = true
        sailButton.isHidden = true
        _selectedBoat = nil
        _boatCourse.removeAll()
        _buildParts.removeAll()
        scene.clearPlot()
        scene.clearJobMarkers()
    }
    

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MapViewController._map = self
        self.scene = skView.scene as? MapScene
        //self.scene!.mapModel = self.mapModel
        toolTip.layer.cornerRadius = 8
        toolTip.layer.borderWidth = 0.5
        User.sharedInstance.addObserver(self)
        do {
            self.scene!.setup( data: try JSONSerialization.load(path: "PirateerAssets/map_view.json") as! Dictionary<String, AnyObject> )
        } catch { fatalError() }
        
        let frameSize = CGSize(width: (self.scene!.size.width), height: (self.scene!.size.height))
        let interfaceView = UIView(frame: CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height))
        interfaceView.backgroundColor = UIColor.clear
        interfaceView.isUserInteractionEnabled = true
        scrollView.contentSize = frameSize
        scrollView.addSubview(interfaceView)
        scrollView.delegate = self
        let pad = self.scene!.padding
        scrollView.contentOffset = CGPoint(x:1150,y:600) + pad
        /*wallet.goldLabel.text = String(User.sharedInstance.gold)
        wallet.silverLabel.text = String(User.sharedInstance.silver)*/
        NotificationCenter.default.addObserver(self,
            selector: #selector(MapViewController.applicationWillEnterForeground),
            name: Notification.Name.foreground, object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(MapViewController.applicationWillEnterBackground),
            name: Notification.Name.background, object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(MapViewController.townUpgraded(_:)),
            name: Notification.Name.townUpgraded, object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(MapViewController.jobDelivered(_:)),
            name: Notification.Name.jobDelivered, object: nil)
        /*#if DEBUG
        debugGraph()
        #endif*/
        
        AudioManager.sharedInstance.playSound(sound:"bg_map", looping: true)
        TownController.setController(controller: self)
        for vert in Map.sharedInstance.graph.vertices {
            let town = vert.data as? TownModel
            guard town != nil else { continue }
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x:vert.position.x - 16 + pad.width,
                                  y:-vert.position.y - 16 - pad.height,
                                  width: 32, height: 32)
            interfaceView.addSubview(button)

            let sprite = TownView(imageNamed: "town_marker_disabled")
            sprite.setup()
            sprite.position = CGPoint(x: vert.position.x,
                                      y: vert.position.y)
            sprite.zPosition = 2
            scene!.addChild(sprite)
            
            let label = SKLabelNode(text: town!.name)
            label.position = CGPoint(x:vert.position.x,
                                     y:vert.position.y - 48)
            label.fontSize = 16
            label.zPosition = 2
            scene!.addChild(label)
            
            var label_bg_size = label.calculateAccumulatedFrame()
            label_bg_size.origin.x -= 4; label_bg_size.origin.y -= 4
            label_bg_size.size.width += 8; label_bg_size.size.height += 8
            let label_bg = SKShapeNode(rect: label_bg_size, cornerRadius: 4)
            label_bg.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            label_bg.lineWidth = 0
            label_bg.zPosition = 1
            scene!.addChild(label_bg)
            
            let townCtrl = TownController(town: town!, button: button, view: sprite)
            _townControllers.append(townCtrl)
            townCtrl.state = .unselected
        }
        self._selectedTint = tabBarController!.tabBar.tintColor
        tabBarController!.tabBar.unselectedItemTintColor = UIColor.lightGray
        BoatController.setController(controller:self)
        for boatModel in User.sharedInstance.boats {
            _ = addBoat( boat: boatModel )
        }
    }
    
    func plotCourseForBoat ( boat: BoatController ) {
        let course = boat.model.course
        for i in 1..<course.count {
            scene.plotRouteToTown( start: townControllerForModel(model: course[i-1]),
                                   end: townControllerForModel(model: course[i]), image: "nav_plot" )
        }
        scene.plotCourseForBoat(boat: boat)
    }
    
    func plotRoutesForTown ( townCtrl: TownController, distance: CGFloat )
    {
        townCtrl.state = .selected
        let startPos = Map.sharedInstance.townPosition( town: townCtrl.model )
        var paths = [[Edge<WorldNode>]]()
        for controller in _townControllers {
            if _boatCourse.contains(where: { $0 === controller }) { continue }
            let endPos = Map.sharedInstance.townPosition( town: controller.model )
            let dist = startPos.distance( endPos )
            if dist > distance {
                controller.state = .blocked
            }
            else if controller.model.level > 0 {
                controller.state = .unselected
            }
            if (controller.state != .unselected) { continue }
            paths.append(Map.sharedInstance.getRoute(start: townCtrl.model, end: controller.model))
        }
        scene.plotRoutesForTown(town: townCtrl.model, paths: paths, distance: distance)
    }
    
    @objc func townUpgraded(_ notification: Notification) {
        if mode == .plot {
            var town = _boatCourse.popLast()
            if town == nil {
                let townModel = _selectedBoat!.model.town
                town = townControllerForModel(model: townModel!)
            }
            town!.state = .unselected
            townSelected(town: town!)
        }
    }
    
    @objc func jobDelivered(_ notification: Notification) {
        let town =      notification.userInfo!["Town"] as! TownModel
        let gold =      notification.userInfo!["Gold"] as! Int
        let silver =    notification.userInfo!["Silver"] as! Int
        let quiet =     notification.userInfo!["Quiet"] as! Bool
        if quiet == false {
            scene.showMoney(town: town, gold: gold, silver: silver)
        }
    }
    
    func boatAdded      (boat: BoatModel) {
        _ = addBoat(boat: boat)
    }
    
    func boatRemoved    (boat: BoatModel) {
        let boatController = boatControllerForModel(model: boat)
        _boatControllers.removeAll(where: {$0 === boatController})
        boatController.view.sprite.removeFromParent()
        if let town = boat.town {
            let townController = townControllerForModel(model: town)
            townController.updateView()
        }
        if _selectedBoat! === boatController {
            reset()
        }
    }
    
    internal func goldUpdated(oldValue: Int, newValue: Int) {
        wallet.goldLabel.text = String(newValue)
    }
    
    internal func silverUpdated(oldValue: Int, newValue: Int) {
        wallet.silverLabel.text = String(newValue)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        if let boat = _selectedBoat {
            scene.plotJobMarkers(boat: boat.model)
        }
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if mode == .build {
            tabBar(enabled: false)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func townControllerForModel (model: TownModel) -> TownController
    {
        let townController = _townControllers.first(where: {$0.model === model})
        return townController!
    }
    
    func boatControllerForModel (model: BoatModel) -> BoatController
    {
        let boatController = _boatControllers.first(where: {$0.model === model})
        return boatController!
    }
    
    func boatSelected ( boat: BoatController)
    {
        stopTracking()
        reset()
        self._selectedBoat = boat
        let town = _selectedBoat?.model.town
        if town != nil {
            let scene_pos = Map.sharedInstance.townPosition( town: town! )
            let screen_pos = screenPosition( position: scene_pos )
            scrollView.contentOffset = screen_pos
            townSelected( town: townControllerForModel( model: town! ) )
        } else {
            startTracking( boat: self._selectedBoat! )
            plotCourseForBoat ( boat: self._selectedBoat! )
            cargoButton.isHidden = false
        }
    }
    
    func boatSelected ( with index: Int )
    {
        let boat = _boatControllers[index]
        boatSelected(boat: boat)
    }
    
    func startTracking ( boat: BoatController )
    {
        stopTracking()
        _trackBoat = true
        let action = SKAction.repeatForever(SKAction.customAction(withDuration: 1000, actionBlock: { (node: SKNode, dt: CGFloat) in
            let pos = node.position
            let screen_pos = self.screenPosition(position: pos)
            self.scrollView.contentOffset = screen_pos
        }))
        _selectedBoat!.view.sprite.run(action, withKey: "track")
    }

    func townSelected ( town: TownController ) {
        if mode == .plot && town.state == .unselected {
            scene.clearPlot()
            var townCtrl : TownController?
            _boatCourse.append(town)
            if _boatCourse.count == 1 {
                townCtrl = townControllerForModel( model: _selectedBoat!.model.town! )
                cargoButton.isHidden = false
                sailButton.isHidden = true
                cancelButton.isHidden = false
            } else {
                cargoButton.isHidden = true
                sailButton.isHidden = false
                townCtrl = town
                for i in 1..<_boatCourse.count {
                    scene.plotRouteToTown( start: _boatCourse[i-1], end: _boatCourse[i], image: "nav_plotted" )
                }
            }
            plotRoutesForTown( townCtrl: townCtrl!,
                               distance: self._selectedBoat!.model.endurance * 0.5)
            town.state = .selected
        } else if mode == .build || mode == .buy {
            let boat = BoatModel(type: _buildType!, name: BoatModel.makeName(), town: town.model)
            if mode == .build {
                User.sharedInstance.purchaseBoatWithParts(boat: boat, parts: _buildParts)
            } else {
                User.sharedInstance.purchaseBoatWithMoney(boat: boat, parts: _buildParts)
            }
            //_ = addBoat(boat: boat)
            User.sharedInstance.save()
            //tabBarController?.tabBar.isHidden = false
            tabBar(enabled: true)
            reset()
        } else {
            performSegue( withIdentifier: "TownSegue", sender: town )
        }
    }
    
    func tabBar (enabled: Bool) {
        if enabled {
            tabBarController?.tabBar.isUserInteractionEnabled = true
            tabBarController?.tabBar.tintColor = _selectedTint
            tabBarController?.tabBar.unselectedItemTintColor = UIColor.lightGray
        } else {
            tabBarController?.tabBar.isUserInteractionEnabled = false
            tabBarController?.tabBar.tintColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            tabBarController?.tabBar.unselectedItemTintColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        }
    }
    
    func stopTracking ( )
    {
        if _trackBoat == true && self._selectedBoat != nil {
            self._selectedBoat!.view.sprite.removeAction(forKey: "track")
            cargoButton.isHidden = true
        }
        _trackBoat = false
    }
    
    func screenPosition ( position: CGPoint) -> CGPoint
    {
        var new_position = position
        let pad = self.scene!.padding
        new_position.y = -new_position.y
        new_position.x += pad.width
        new_position.y -= pad.height
        new_position -= self.view.center
        return new_position
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func addBoat ( boat: BoatModel ) -> BoatController
    {
        let view = BoatView( boatType: boat.type )
        let boatController = BoatController( model: boat, view: view )
        _boatControllers.append( boatController )
        view.sprite.zPosition = 4
        self.scene!.addChild( view.sprite )
        if boatController.model.isMoored != true {
            boatController.sail()
        } else {
            let tc = townControllerForModel(model: boat.town!)
            tc.updateView()
            view.sprite.isHidden = true
        }
        return boatController
    }
    
    func boatArrived( boat: BoatController )
    {
        boat.view.sprite.isHidden = true
        let town = townControllerForModel(model: boat.model.town!)
        town.updateView()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? TownViewController
        {
            let town = sender as! TownController
            vc.townController = town
        } else if let vc = segue.destination as? JobViewController {
            vc.boatController = _selectedBoat
        }
    }
    

}

extension MapViewController : UIScrollViewDelegate
{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scene.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTracking()
    }
}





