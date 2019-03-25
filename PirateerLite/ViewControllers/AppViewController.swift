//
//  AppController.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 31/1/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import UIKit

class AppViewController: UITabBarController {
    var mapController : MapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapController = viewControllers?[0] as? MapViewController
        self.delegate = self
    }
}

extension AppViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TabBarAnimatedTransitioning()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let vc = viewController as? UINavigationController {
            vc.viewControllers = [vc.viewControllers.first!]
        }
    }
}

final class TabBarAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    /*
     Tells your animator object to perform the transition animations.
     */
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destination = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        
        destination.alpha = 0.0
        destination.transform = .init(scaleX: 1.5, y: 1.5)
        transitionContext.containerView.addSubview(destination)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            destination.alpha = 1.0
            destination.transform = .identity
        }, completion: { transitionContext.completeTransition($0) })
    }
    
    /*
     Asks your animator object for the duration (in seconds) of the transition animation.
     */
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
}
