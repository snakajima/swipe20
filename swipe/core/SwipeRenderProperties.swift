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
    var isHidden:Bool { get }
}

// https://stackoverflow.com/questions/24274913/equivalent-of-or-alternative-to-cgpathapply-in-swift
// NOT https://stackoverflow.com/questions/3051760/how-to-get-a-list-of-points-from-a-uibezierpath/5714872#5714872


extension SwipeRenderProperties {
    /// Applies tween properties to the element
    func apply(target:SwipeRenderLayer, ratio:Double, from:SwipeRenderProperties?, element:SwipeElement) {
        var xf = CATransform3DIdentity
        var r = ratio
        
        guard let from = from else {
            target.opacity = opacity
            target.updateFrame(frame: frame, element: element)
            xf.m34 = -1.0/500; // add the perspective
            xf = CATransform3DRotate(xf, rotX, 1, 0, 0)
            xf = CATransform3DRotate(xf, rotY, 0, 1, 0)
            xf = CATransform3DRotate(xf, rotZ, 0, 0, 1)
            target.transform = xf
            return
        }
        
        target.opacity = from.opacity.mix(opacity, ratio)
        
        if self.isAnimationRequired(other: from) {
            var newFrame = CGRect(x: from.frame.minX.mix(frame.minX, ratio),
                                  y: from.frame.minY.mix(frame.minY, ratio),
                                  width: from.frame.width.mix(frame.width, ratio),
                                  height: from.frame.height.mix(frame.height, ratio))
            
            if isHidden != from.isHidden {
                // Perform the drawing animation
                if var path = element.path {
                    target.frame = isHidden ? from.frame : frame
                    let size = path.boundingBox.size
                    let sx = target.frame.size.width / size.width
                    let sy = target.frame.size.height / size.height
                    var xf = CGAffineTransform(scaleX: sx, y: sy)
                    path = path.copy(using: &xf)!
                    let elements = path.elements

                    let count = Int(Double(elements.count) * (isHidden ? 1 - ratio : ratio))
                    
                    target.updatePath(path: elements[0..<count].reduce(CGMutablePath(), { (path, element) -> CGMutablePath in
                        element.apply(path: path)
                    }))
                } else {
                    // TDB: for non-path element animation
                }
                
                let rotX = from.rotX.mix(self.rotX, 1)
                let rotY = from.rotY.mix(self.rotY, 1)
                let rotZ = from.rotZ.mix(self.rotZ, 1)

                xf.m34 = -1.0/500; // add the perspective
                xf = CATransform3DRotate(xf, rotX, 1, 0, 0)
                xf = CATransform3DRotate(xf, rotY, 0, 1, 0)
                xf = CATransform3DRotate(xf, rotZ, 0, 0, 1)
                target.transform = xf
            } else {
                switch(animationStyle) {
                case .bounce:
                    (newFrame, xf) = bounce(ratio: ratio, from: from, newFrame: newFrame, xf: xf)
                case .jump:
                    (newFrame, xf, r) = jump(ratio: ratio, from: from, xf: xf, flip:false)
                case .summersault:
                    (newFrame, xf, r) = jump(ratio: ratio, from: from, xf: xf, flip:true)
                case .leap:
                    (newFrame, xf, r) = leap(ratio: ratio, from: from, xf: xf)
                default:
                    break
                }
                target.updateFrame(frame: newFrame, element: element)
                
                let rotX = from.rotX.mix(self.rotX, ratio)
                let rotY = from.rotY.mix(self.rotY, ratio)
                let rotZ = from.rotZ.mix(self.rotZ, ratio)

                xf.m34 = -1.0/500; // add the perspective
                xf = CATransform3DRotate(xf, rotX, 1, 0, 0)
                xf = CATransform3DRotate(xf, rotY, 0, 1, 0)
                xf = CATransform3DRotate(xf, rotZ, 0, 0, 1)
                target.transform = xf
            }
        } else {
            let rotX = from.rotX.mix(self.rotX, r)
            let rotY = from.rotY.mix(self.rotY, r)
            let rotZ = from.rotZ.mix(self.rotZ, r)

            xf.m34 = -1.0/500; // add the perspective
            xf = CATransform3DRotate(xf, rotX, 1, 0, 0)
            xf = CATransform3DRotate(xf, rotY, 0, 1, 0)
            xf = CATransform3DRotate(xf, rotZ, 0, 0, 1)
            target.transform = xf
        }
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
    
    func leap(ratio:Double, from:SwipeRenderProperties, xf:CATransform3D) -> (CGRect, CATransform3D, Double) {
        var xfNew = xf
        let x, y:CGFloat
        let r0 = 0.4 // anticipate
        let r2 = 0.4 // squeezing
        let r1 = 1.0 - r0 - r2 // jump
        let dx = frame.minX - from.frame.minX
        let dy = frame.minY - from.frame.minY
        let dir = atan2(dx, dy)
        let size:CGSize
        let effectiveRatio:Double
        switch(ratio) {
        case _ where ratio < r0:
            x = from.frame.minX
            y = from.frame.minY
            let r = CGFloat(sin(ratio * ratio / r0 / r0 * .pi))
            xfNew = CATransform3DRotate(xf, -r * cos(dir) * 0.8, 1, 0, 0)
            xfNew = CATransform3DRotate(xfNew, r * sin(dir) * 0.8, 0, 1, 0)
            size = from.frame.size
            effectiveRatio = 0
        case _ where ratio > (1 - r2):
            x = frame.minX
            y = frame.minY
            let r = CGFloat(sin((1 - ratio) / r2 * .pi))
            xfNew = CATransform3DRotate(xf, -r * cos(dir) * 0.8, 1, 0, 0)
            xfNew = CATransform3DRotate(xfNew, r * sin(dir) * 0.8, 0, 1, 0)
            size = frame.size
            effectiveRatio = 1
        default:
            let r = (ratio - r0) / r1
            x = from.frame.minX.mix(frame.minX, r)
            y = from.frame.minY.mix(frame.minY, r)
            size = CGSize(width:from.frame.width.mix(frame.width, r),
                          height:from.frame.height.mix(frame.height, r))
            effectiveRatio = r
        }
            
        return (CGRect(origin: CGPoint(x: x, y: y), size: size), xfNew, effectiveRatio)
    }

    func jump(ratio:Double, from:SwipeRenderProperties, xf:CATransform3D, flip:Bool) -> (CGRect, CATransform3D, Double) {
        var xfNew = xf
        let x, y:CGFloat
        let r0 = 0.25 // anticipate
        let r2 = 0.25 // squeezing
        let r1 = 1.0 - r0 - r2 // jump
        let height = CGFloat(360.0)
        let size:CGSize
        let effectiveRatio:Double
        switch(ratio) {
        case _ where ratio < r0:
            x = from.frame.minX
            y = from.frame.minY
            let r = CGFloat(sin(ratio * ratio / r0 / r0 * .pi))
            xfNew = CATransform3DScale(xf, 1.0 + r * 0.25, 1.0 - r * 0.2, 1.0)
            size = from.frame.size
            effectiveRatio = 0
        case _ where ratio > (1 - r2):
            x = frame.minX
            y = frame.minY
            let r = CGFloat(sin((1 - ratio) / r2 * .pi))
            xfNew = CATransform3DScale(xf, 1.0 + r * 0.25, 1.0 - r * 0.2, 1.0)
            size = frame.size
            effectiveRatio = 1.0
        default:
            let r = (ratio - r0) / r1
            x = from.frame.minX.mix(frame.minX, r)
            y = from.frame.minY.mix(frame.minY, r) - height * CGFloat(1 - 4 * (r - 0.5) * (r - 0.5))
            if (flip) {
                let dir:CGFloat = from.frame.minX < frame.minX ? 1 : -1
                xfNew = CATransform3DRotate(xf, dir * .pi * 2 * CGFloat(r), 0, 0, 1)
            }
            size = CGSize(width:from.frame.width.mix(frame.width, r),
                          height:from.frame.height.mix(frame.height, r))
            effectiveRatio = r
        }
            
        return (CGRect(origin: CGPoint(x: x, y: y), size: size), xfNew, effectiveRatio)
    }

    func isAnimationRequired(other:SwipeRenderProperties) -> Bool {
        return frame != other.frame
            || rotX != other.rotX
            || rotY != other.rotY
            || rotZ != other.rotZ
            || isHidden != other.isHidden
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
