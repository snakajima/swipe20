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
    var contents: Any? { get set }
}

extension SwipeRenderLayer {
    func updateFrame(frame:CGRect, element:SwipeElement) {
        if let path = element.path {
            let sx = frame.size.width / element.pathBox.size.width
            let sy = frame.size.height / element.pathBox.size.height
            var xf = CGAffineTransform(scaleX: sx, y: sy)
            let pathResized = path.copy(using: &xf)!
            if let shapeLayer = self as? CAShapeLayer {
                shapeLayer.path = pathResized
            } else {
                let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
                let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
                guard let context = CGContext(data: nil, width: Int(frame.size.width), height: Int(frame.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return }

                context.addPath(pathResized)
                context.setLineWidth(10.0)
                context.setStrokeColor(OSColor.blue.cgColor)
                context.strokePath()
                let image = context.makeImage()
                self.contents = image
            }
        }
        self.frame = frame
    }
}

