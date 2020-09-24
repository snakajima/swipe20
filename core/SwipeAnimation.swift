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
    var frame:CGRect { get }
    var opacity:Float { get }
    var transform:CATransform3D { get }
    var anchorPoint:CGPoint { get }
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
        let left = 1.0 - ratio
        target.opacity = from.opacity * Float(left) + to.opacity * Float(ratio)
        let fr = from.frame
        target.frame = CGRect(x: fr.minX * left + to.frame.minX * ratio,
                              y: fr.minY * left + to.frame.minY * ratio,
                              width: fr.width * left + to.frame.width * ratio,
                              height: fr.height * left + to.frame.height * ratio)
    }
}

class SwipeAnimation {
    let duration:Double
    var beginTime:CFTimeInterval = 0
    init(duration:Double) {
        self.duration = duration
    }
    
    func start(callback:@escaping (Double)->Void) {
        beginTime = CACurrentMediaTime()
        tick(callback: callback)
    }
    
    func tick(callback:@escaping (Double)->Void) {
        let delta = CACurrentMediaTime() - beginTime
        if delta > duration {
            callback(1.0)
            return
        }
        callback(delta / duration)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.tick(callback: callback)
        }
    }
}
