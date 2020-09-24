//
//  SwipeRenderLayer.swift
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
        
        target.opacity = from.opacity.mix(to.opacity, ratio)
        target.frame = CGRect(x: from.frame.minX.mix(to.frame.minX, ratio),
                              y: from.frame.minY.mix(to.frame.minY, ratio),
                              width: from.frame.width.mix(to.frame.width, ratio),
                              height: from.frame.height.mix(to.frame.height, ratio))
        let t0 = from.transform
        let t1 = to.transform
        target.transform = CATransform3D(m11: t0.m11.mix(t1.m11, ratio), m12: t0.m12.mix(t1.m12, ratio), m13: t0.m13.mix(t1.m13, ratio), m14: t0.m14.mix(t1.m14, ratio), m21: t0.m21.mix(t1.m21, ratio), m22: t0.m22.mix(t1.m22, ratio), m23: t0.m23.mix(t1.m23, ratio), m24: t0.m24.mix(t1.m24, ratio), m31: t0.m31.mix(t1.m31, ratio), m32: t0.m32.mix(t1.m32, ratio), m33: t0.m33.mix(t1.m33, ratio), m34: t0.m34.mix(t1.m34, ratio), m41: t0.m41.mix(t1.m41, ratio), m42: t0.m42.mix(t1.m42, ratio), m43: t0.m43.mix(t1.m43, ratio), m44: t0.m44.mix(t1.m44, ratio))
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
