//
//  SwipeRenderProperties.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/24/20.
//

import QuartzCore

protocol SwipeRenderProperties {
    var frame:CGRect { get }
    var opacity:Float { get }
    var rotX:CGFloat { get }
    var rotY:CGFloat { get }
    var rotZ:CGFloat { get }
    var anchorPoint:CGPoint { get }
    var animationStyle: SwipeAnimation.Style { get }
}

extension SwipeRenderProperties {
    func apply(target:RenderLayer, ratio:Double, from:SwipeRenderProperties?) {
        guard let from = from else {
            target.opacity = opacity
            target.frame = frame
            return
        }
        
        target.opacity = from.opacity.mix(opacity, ratio)
        
        var xf = CATransform3DIdentity
        var newFrame = CGRect(x: from.frame.minX.mix(frame.minX, ratio),
                              y: from.frame.minY.mix(frame.minY, ratio),
                              width: from.frame.width.mix(frame.width, ratio),
                              height: from.frame.height.mix(frame.height, ratio))
        
        if animationStyle == .gravity {
            let y:CGFloat
            let r0 = 0.4 // going down
            let r1 = 0.2 // squeezing
            let r2 = 0.4 // going up
            switch(ratio) {
            case _ where ratio < r0: y = from.frame.minY * CGFloat(1 - ratio * ratio / r0 / r0)
            case _ where ratio > (1 - r2): y = frame.minY * CGFloat(1 - (1 - ratio) * (1 - ratio) / r2 / r2)
            default:
                y = 0
                let r = CGFloat(sin((ratio - r0) / r1 * .pi))
                xf = CATransform3DScale(xf, 1.0 + r * 0.25, 1.0 - r * 0.2, 1.0)
            }
                
            newFrame = CGRect(origin: CGPoint(x: newFrame.origin.x, y: y), size: newFrame.size)
        }
        target.frame = newFrame
        
        let rotX = from.rotX.mix(self.rotX, ratio)
        let rotY = from.rotY.mix(self.rotY, ratio)
        let rotZ = from.rotZ.mix(self.rotZ, ratio)
        
        xf.m34 = -1.0/500; // add the perspective
        let m = CGFloat(CGFloat.pi / 180.0) // LATER: static
        xf = CATransform3DRotate(xf, rotX * m, 1, 0, 0)
        xf = CATransform3DRotate(xf, rotY * m, 0, 1, 0)
        xf = CATransform3DRotate(xf, rotZ * m, 0, 0, 1)
        target.transform = xf
    }
}

private extension Float {
    func mix(_ to:Float, _ ratio:Double) -> Float {
        return self * Float(1 - ratio) + to * Float(ratio)
    }
}

private extension CGFloat {
    func mix(_ to:CGFloat, _ ratio:Double) -> CGFloat {
        return self * CGFloat(1 - ratio) + to * CGFloat(ratio)
    }
}
