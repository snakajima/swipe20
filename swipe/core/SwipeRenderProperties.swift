//
//  SwipeRenderProperties.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/24/20.
//

import QuartzCore

/// Source of properties to be applied to elements
public protocol SwipeRenderProperties {
    var frame:CGRect { get }
    var opacity:Float { get }
    var rotX:CGFloat { get }
    var rotY:CGFloat { get }
    var rotZ:CGFloat { get }
    var anchorPoint:CGPoint { get }
    var animationStyle: SwipeAnimation.Style { get }
}

extension SwipeRenderProperties {
    /// Applies tween properties to the element
    func apply(target:SwipeRenderLayer, ratio:Double, from:SwipeRenderProperties?) {
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
        
        switch(animationStyle) {
        case .bounce:
            (newFrame, xf) = bounce(ratio: ratio, from: from, newFrame: newFrame, xf: xf)
        case .jump:
            (newFrame, xf) = jump(ratio: ratio, from: from, newFrame: newFrame, xf: xf)
        case .leap:
            (newFrame, xf) = leap(ratio: ratio, from: from, newFrame: newFrame, xf: xf)
        default:
            break
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
    
    func bounce(ratio:Double, from:SwipeRenderProperties, newFrame:CGRect, xf:CATransform3D) -> (CGRect, CATransform3D) {
        var xfNew = xf
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
            xfNew = CATransform3DScale(xf, 1.0 + r * 0.25, 1.0 - r * 0.2, 1.0)
        }
            
        return (CGRect(origin: CGPoint(x: newFrame.origin.x, y: y), size: newFrame.size), xfNew)
    }
    
    func leap(ratio:Double, from:SwipeRenderProperties, newFrame:CGRect, xf:CATransform3D) -> (CGRect, CATransform3D) {
        var xfNew = xf
        let x, y:CGFloat
        let r0 = 0.5 // anticipate
        let r2 = 0.1 // squeezing
        let r1 = 1.0 - r0 - r2 // jump
        let dx = frame.minX - from.frame.minX
        let dy = frame.minY - from.frame.minY
        let dir = atan2(dx, dy)
        switch(ratio) {
        case _ where ratio < r0:
            x = from.frame.minX
            y = from.frame.minY
            let r = CGFloat(sin(ratio * ratio / r0 / r0 * .pi))
            xfNew = CATransform3DRotate(xf, -r * cos(dir), 1, 0, 0)
            xfNew = CATransform3DRotate(xfNew, r * sin(dir), 0, 1, 0)
        case _ where ratio > (1 - r2):
            x = frame.minX
            y = frame.minY
            let r = CGFloat(sin((1 - ratio) / r2 * .pi))
            xfNew = CATransform3DRotate(xf, -r * cos(dir), 1, 0, 0)
            xfNew = CATransform3DRotate(xfNew, r * sin(dir), 0, 1, 0)
        default:
            let r = sin((ratio - r0) / r1 * .pi / 2)
            x = from.frame.minX.mix(frame.minX, r)
            y = from.frame.minY.mix(frame.minY, r)
        }
            
        return (CGRect(origin: CGPoint(x: x, y: y), size: newFrame.size), xfNew)
    }

    func jump(ratio:Double, from:SwipeRenderProperties, newFrame:CGRect, xf:CATransform3D) -> (CGRect, CATransform3D) {
        var xfNew = xf
        let x, y:CGFloat
        let r0 = 0.5 // anticipate
        let r2 = 0.1 // squeezing
        let r1 = 1.0 - r0 - r2 // jump
        let height = CGFloat(200.0)
        switch(ratio) {
        case _ where ratio < r0:
            x = from.frame.minX
            y = from.frame.minY
            let r = CGFloat(sin(ratio * ratio / r0 / r0 * .pi))
            xfNew = CATransform3DScale(xf, 1.0 + r * 0.25, 1.0 - r * 0.2, 1.0)
        case _ where ratio > (1 - r2):
            x = frame.minX
            y = frame.minY
            let r = CGFloat(sin((1 - ratio) / r2 * .pi))
            xfNew = CATransform3DScale(xf, 1.0 + r * 0.111, 1.0 - r * 0.1, 1.0)
        default:
            let r = (ratio - r0) / r1
            x = from.frame.minX.mix(frame.minX, r)
            y = from.frame.minY.mix(frame.minY, r) + height * CGFloat(1 - 4 * (r - 0.5) * (r - 0.5))
        }
            
        return (CGRect(origin: CGPoint(x: x, y: y), size: newFrame.size), xfNew)
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
