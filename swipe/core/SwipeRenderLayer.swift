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
            if let shapeLayer = self as? CAShapeLayer {
                var xf = CGAffineTransform(scaleX: sx, y: sy)
                let pathResized = path.copy(using: &xf)!
                shapeLayer.path = pathResized
            } else {
                var xf = CGAffineTransform(translationX: 0, y: element.pathBox.size.height)
                xf = xf.scaledBy(x: sx, y: -sy)
                let pathResized = path.copy(using: &xf)!
                let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
                let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
                let lineWidth = CGFloat(element.lineWidth ?? 10.0)
                guard let context = CGContext(data: nil, width: Int(frame.size.width + lineWidth*2), height: Int(frame.size.height + lineWidth*2), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return }

                context.translateBy(x: lineWidth, y: lineWidth)
                context.addPath(pathResized)
                context.setLineWidth(lineWidth)
                context.setStrokeColor(OSColor.blue.cgColor)
                context.setLineCap(.round)
                context.setLineJoin(.round)
                context.setMiterLimit(0.1)
                context.strokePath()
                let image = context.makeImage()
                self.contents = image
                self.frame = CGRect(origin: CGPoint(x: frame.minX - lineWidth, y: frame.minY - lineWidth), size: CGSize(width: frame.size.width + lineWidth, height: frame.size.height + lineWidth))
                return
            }
        }
        self.frame = frame
    }
}

