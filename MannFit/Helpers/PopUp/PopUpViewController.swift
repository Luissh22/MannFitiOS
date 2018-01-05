//
//  PopUpViewController.swift
//  MannFit
//
//  Created by Daniel Till on 1/3/18.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
    
    var popUpView: UIView
    var dismissible: Bool
    
    init(view: UIView, dismissible: Bool) {
        self.popUpView = view
        self.dismissible = dismissible
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        self.popUpView = UIView()
        self.dismissible = true
        self.popUpView.translatesAutoresizingMaskIntoConstraints = false
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(popUpView)
        
        // layout popUpView
        self.popUpView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalPadding: CGFloat = 30.0
        NSLayoutConstraint.activate([
            self.popUpView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: horizontalPadding),
            self.popUpView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -horizontalPadding),
            self.popUpView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.popUpView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            ])
    }
    
    @objc fileprivate func handleTap(_ sender: UITapGestureRecognizer) {
        var point = sender.location(in: self.view)
        point = self.popUpView.convert(point, from:self.view)
        if !self.popUpView.bounds.contains(point) && dismissible {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension PopUpViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopUpPresentationController(presentedViewController: presented, presenting: source)
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopUpViewAnimation(direction: .In)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopUpViewAnimation(direction: .Out)
    }
}
