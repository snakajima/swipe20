//
//  SwipeRenderLayer.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/24/20.
//
import QuartzCore

/// Protocol to control animatable elements
public protocol SwipeRenderLayer: NSObjectProtocol {
    var frame:CGRect { get set }
    var opacity:Float { get set }
    var transform:CATransform3D { get set }
    var anchorPoint:CGPoint { get set }
}

extension SwipeRenderLayer {
    func updateFrame(frame:CGRect, element:SwipeElement) {
        if let path = element.path {
            if let shapeLayer = self as? CAShapeLayer {
                let sx = frame.size.width / element.pathBox.size.width
                let sy = frame.size.height / element.pathBox.size.height
                var xf = CGAffineTransform(scaleX: sx, y: sy)
                shapeLayer.path = path.copy(using: &xf)
            } else {
                print("SwipeRenderLayer: ###Error")
            }
        } else {
            print("no element.path")
        }
        self.frame = frame
    }
}

