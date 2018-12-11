//
//  PresentationController.swift
//  portfolio
//
//  Created by Formative Mini on 11/7/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit

class ThreeQuarterPresentationController: UIPresentationController, UIGestureRecognizerDelegate{
   
    let blackBackgroundView = UIView()
    let touchView = UIView()
    var panGR = UIPanGestureRecognizer()
    
   var initialTouchPoint: CGPoint = CGPoint(x: 10, y: 0)
    
    @objc func panGestureDismiss(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.presentedView?.window)
        
        if sender.state == UIGestureRecognizer.State.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizer.State.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.presentedView!.frame = CGRect(x: 10, y: touchPoint.y - (self.presentedView!.frame.height/15), width: self.presentedView!.frame.width, height: self.presentedView!.frame.height)
            }
        } else if sender.state == UIGestureRecognizer.State.ended || sender.state == UIGestureRecognizer.State.cancelled {
            if touchPoint.y - initialTouchPoint.y > 225 {
                self.presentedViewController.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.presentedView!.frame = CGRect(x: 10, y: self.containerView!.frame.height/5, width: self.presentedView!.frame.width, height: self.presentedView!.frame                                                        .height)
                })
            }
        }
    }

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        
        touchView.backgroundColor = .black
        touchView.tintColor = .white
        touchView.layer.masksToBounds = false
        touchView.layer.shadowRadius = 4
        touchView.layer.shadowOpacity = 0.2
        touchView.layer.shadowColor = UIColor.white.cgColor
        touchView.layer.shadowOffset = CGSize(width: 0 , height:1)
        blackBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        blackBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blackBackgroundView.isUserInteractionEnabled = true
        self.touchView.frame.size.height = 44
        self.touchView.frame.size.width = self.presentedView!.frame.width
        panGR = UIPanGestureRecognizer(target: self, action: #selector(panGestureDismiss(_:)))
        panGR.delegate = self
        self.touchView.addGestureRecognizer(panGR)
    }
    
//    func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        print("Passing all touches to the next view (if any), in the view stack.")
//        return false
//    }
    override var frameOfPresentedViewInContainerView: CGRect{
        let viewHeight = self.containerView!.frame.height*0.75
        return CGRect(origin: CGPoint(x: 10, y: self.containerView!.frame.height/5), size: CGSize(width: self.containerView!.frame.width - 20, height: viewHeight))
    }
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blackBackgroundView.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blackBackgroundView.removeFromSuperview()
        })
    }
    override func presentationTransitionWillBegin() {
        self.blackBackgroundView.alpha = 0
        self.containerView?.addSubview(blackBackgroundView)
        self.presentedView?.insertSubview(touchView, at: 1)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blackBackgroundView.alpha = 1
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            
        })
    }
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.layer.masksToBounds = true
        presentedView!.layer.cornerRadius = 20
    }
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        self.presentedView?.frame = frameOfPresentedViewInContainerView
        blackBackgroundView.frame = containerView!.bounds
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
}
