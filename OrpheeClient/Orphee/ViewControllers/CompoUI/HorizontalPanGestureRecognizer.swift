//
//  HorizontalPanGestureRecognizer.swift
//  CompoUI
//
//  Created by John Bobington on 23/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

extension Set {
    func random() -> Set.Element {
        let idx = arc4random_uniform(UInt32(self.count))
        var gen = self.startIndex
        for _ in 0..<idx { gen = gen.successor() }
        return self[gen]
    }
}

class HorizontalPanGestureRecognizer: UIPanGestureRecognizer, UIGestureRecognizerDelegate {

    enum DragDirection: Int {
        case Unknown = 0
        case Left = 1
        case Right = -1
    }

    var lastDirection = DragDirection.Unknown
    var startPoint = CGPointZero

    override init(target: AnyObject?, action: Selector) {
        super.init(target: target, action: action)

        self.delegate = self
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event!)
        if let touch = touches.first {
            self.startPoint = touch.locationInView(self.view)
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard self.state != UIGestureRecognizerState.Failed else { return }
        let lPt = touches.random().locationInView(self.view)//locationInView(self.view)
        let sPt = self.startPoint
        super.touchesMoved(touches, withEvent: event!)

//                print("first Pt:", sPt, "last Pt:", lPt)
        let mvX = fabs(fabs(lPt.x) - fabs(sPt.x))
        let mvY = fabs(fabs(lPt.y) - fabs(sPt.y))
        //        print("X axis moved:", mvX, "Y axis moved:", mvY)
        //         rotated view: horizontal pan is on the Y axis
        guard (mvY) < (mvX) else { print("pan failed"); self.state = .Failed; return }
        if self.state == .Possible {
//        print("state is .changed", self.state == .Changed, " --- state is .possible", self.state == .Possible)
            self.lastDirection = .Right
            if sPt.x > lPt.x {
                self.lastDirection = .Left
            }
            //            print(lPt, sPt)
//            print("direction:", self.lastDirection)
            self.state = .Changed
        }
    }

    override func reset() {
        self.lastDirection = .Unknown
        self.startPoint = CGPointZero
        //        if self.state == .Possible {
        self.state = .Failed
        //        }
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        self.reset()
    }

    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        self.reset()
    }

    override func translationInView(view: UIView?) -> CGPoint {
        return super.translationInView(view)
    }
    
    override func velocityInView(view: UIView?) -> CGPoint {
        return super.velocityInView(view)
    }
}
