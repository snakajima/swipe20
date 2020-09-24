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
        
        target.opacity = from.opacity.mix(to.opacity, ratio: ratio)
        target.frame = CGRect(x: from.frame.minX.mix(to.frame.minX, ratio: ratio),
                              y: from.frame.minY.mix(to.frame.minY, ratio: ratio),
                              width: from.frame.width.mix(to.frame.width, ratio: ratio),
                              height: from.frame.height.mix(to.frame.height, ratio: ratio))
    }
}

private extension Float {
    func mix(_ to:Float, ratio:Double) -> Float {
        return self * Float(1 - ratio) + to * Float(ratio)
    }
}

private extension CGFloat {
    func mix(_ to:CGFloat, ratio:Double) -> CGFloat {
        return self * CGFloat(1 - ratio) + to * CGFloat(ratio)
    }
}
