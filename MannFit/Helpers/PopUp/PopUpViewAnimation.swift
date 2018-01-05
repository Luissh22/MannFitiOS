//
//  PopUpViewAnimation.swift
//  MannFit
//
//  Created by Daniel Till on 1/4/18.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import UIKit

enum AnimationDirection {
    case In
    case Out
}

internal class PopUpViewAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var to: UIViewController!
    var from: UIViewController!
    let inDuration: TimeInterval = 0.6
    let outDuration: TimeInterval = 0.2
    var direction: AnimationDirection
    
    init(direction: AnimationDirection) {
        self.direction = direction
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return direction == .In ? inDuration : outDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        switch direction {
        case .In:
            guard let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
                let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
            
            self.to = to
            self.from = from
            
            let container = transitionContext.containerView
            container.addSubview(to.view)
        case .Out:
            guard let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
                let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
            
            self.to = to
            self.from = from
        }

        switch direction {
        case .In:
            to.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: inDuration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.curveEaseOut], animations: {
                self.to.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { completed in
                transitionContext.completeTransition(completed)
            })
        case .Out:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: {
                self.from.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.from.view.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
