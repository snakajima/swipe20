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

extension SwipeRenderProperties {
    func apply(target:SwipeRenderLayer, ratio:Double, from:SwipeRenderProperties?, to:SwipeRenderProperties) {
        guard let from = from else {
            target.opacity = to.opacity
            target.frame = to.frame
            return
        }
        
        let left = 1.0 - ratio
        target.opacity = from.opacity * Float(left) + to.opacity * Float(ratio)
        let fr = from.frame
        target.frame = CGRect(x: fr.minX * CGFloat(left) + to.frame.minX * CGFloat(ratio),
                              y: fr.minY * CGFloat(left) + to.frame.minY * CGFloat(ratio),
                              width: fr.width * CGFloat(left) + to.frame.width * CGFloat(ratio),
                              height: fr.height * CGFloat(left) + to.frame.height * CGFloat(ratio))
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1/30) {
            self.tick(callback: callback)
        }
    }
}
