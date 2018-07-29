//
//  PopAnimator.swift
//  FlickrAlbum
//
//  Created by Vineet Singh on 24/07/18.
//  Copyright © 2018 Vineet Singh. All rights reserved.
//

//
//  PopAnimator.swift
//  BeginnerCook
//
//  Created by Vineet Singh on 24/07/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit


class  PopAnimator: NSObject, UIViewControllerAnimatedTransitioning  {
    
    let duration = 1.0
    var presenting = true
    var originFrame = CGRect.zero
    
    
    // MARK: Setup Methods
    
    var dismissCompletion: (()->Void)?
    let detailVCObj = DetailImageVC()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    
   
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let herbView = presenting ? toView :
            transitionContext.view(forKey: .from)!

        let initialFrame = presenting ? originFrame : herbView.frame
        let finalFrame = presenting ? herbView.frame : originFrame

        let xScaleFactor = presenting ?

            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width

        let yScaleFactor = presenting ?

            (initialFrame.height / 2) / finalFrame.height :
            finalFrame.height / initialFrame.height

        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor,
                                               y: yScaleFactor)

        if presenting {
            herbView.transform = scaleTransform
            herbView.center = CGPoint(
                x: initialFrame.midX,
                y: initialFrame.midY)
            herbView.clipsToBounds = true
        }else{

        }

        let albumController = transitionContext.viewController(forKey: presenting ? .to : .from) as! DetailImageVC


        containerView.addSubview(toView)
        containerView.bringSubview(toFront: herbView)

        UIView.animate(withDuration: duration, delay:0.0,
                       usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0,
                       animations: {
                        herbView.transform = self.presenting ?
                            CGAffineTransform.identity : scaleTransform
                        herbView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                        albumController.navBar.alpha = self.presenting ? 1.0 : 0.0
        },
                       completion: { _ in

                        if !self.presenting {
                            self.dismissCompletion?()
                        }

                        transitionContext.completeTransition(true)
        }
    )}
}

