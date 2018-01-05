//
//  PopUpPresentationController.swift
//  MannFit
//
//  Created by Daniel Till on 1/4/18.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import UIKit

class PopUpPresentationController: UIPresentationController {
    
    fileprivate lazy var overlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.alpha = 0.0
        return view
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        overlay.frame = (presentingViewController?.view.bounds)!
    }
    
    override func presentationTransitionWillBegin() {
        overlay.frame = containerView!.bounds
        containerView!.insertSubview(overlay, at: 0)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (coordinatorContext) -> Void in
            self.overlay.alpha = 1.0
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (coordinatorContext) -> Void in
            self.overlay.alpha = 0.0
        }, completion: nil)
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView!.frame = frameOfPresentedViewInContainerView
    }
    
}
