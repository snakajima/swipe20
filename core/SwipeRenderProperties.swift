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
        target.frame = CGRect(x: from.frame.minX.mix(frame.minX, ratio),
                              y: from.frame.minY.mix(frame.minY, ratio),
                              width: from.frame.width.mix(frame.width, ratio),
                              height: from.frame.height.mix(frame.height, ratio))
        
        if animationStyle == .gravity {
            target.frame = target.frame.applying(CGAffineTransform(translationX: 0, y: -CGFloat(ratio * ratio) * target.frame.minY))
        }
        
        let rotX = from.rotX.mix(self.rotX, ratio)
        let rotY = from.rotY.mix(self.rotY, ratio)
        let rotZ = from.rotZ.mix(self.rotZ, ratio)
        
        var xf = CATransform3DIdentity
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
