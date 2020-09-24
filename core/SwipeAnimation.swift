//
//  SwipeAnimation.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/24/20.
//

import QuartzCore

protocol SwipeRenderLayer: NSObjectProtocol {
    var id:Any? { get set }
    var frame:CGRect { get set }
    var opacity:Float { get set }
    var transform:CATransform3D { get set }
    var anchorPoint:CGPoint { get set }
}

protocol SwipeRenderProperties {
    var frame:CGRect? { get }
    var opacity:Float? { get }
    var transform:CATransform3D? { get }
    var anchorPoint:CGPoint? { get }
}

struct SwipeAnimationApplier {
    let target:SwipeRenderLayer
    let from:SwipeRenderProperties
    let to:SwipeRenderProperties
    
    init(target:SwipeRenderLayer, from:SwipeRenderProperties, to:SwipeRenderProperties) {
        self.target = target
        self.from = from
        self.to = to
    }
    
    func apply(ratio:CGFloat, initialing:Bool) {
        if let opacityTo = to.opacity {
            if let opacityFrom = from.opacity {
                target.opacity = opacityFrom * Float(1.0 - ratio) + opacityTo * Float(ratio)
            } else if initialing {
                target.opacity = opacityTo
            }
        }
    }
}

class SwipeAnimation {
    let duration:Double
    var beginTime:CFTimeInterval = 0
    init(duration:Double) {
        self.duration = duration
    }
    
    func start() {
        beginTime = CACurrentMediaTime()
        tick()
    }
    
    func tick() {
        let delta = CACurrentMediaTime() - beginTime
        if delta > duration {
            print("done")
            return
        }
        print("delta", delta)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.tick()
        }
    }
}
