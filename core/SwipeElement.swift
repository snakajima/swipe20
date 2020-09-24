//
//  SwipeElement.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import Cocoa
import CoreImage
import SwiftUI

struct SwipeElement {
    let script:[String:Any]
    let name:String?
    let image:CGImage?
    let path:CGPath?
    
    private let frame:CGRect
    private let backgroundColor:CGColor?
    private let foregroundColor:CGColor?
    private let fillColor:CGColor?
    private let strokeColor:CGColor?
    private let lineWidth:CGFloat?
    private let cornerRadius:CGFloat?
    private let opacity:CGFloat?
    private let anchorPoint:CGPoint?
    private let xf:CATransform3D

    let subElementIds:[String]
    let subElements:[String:SwipeElement]

    init(_ script:[String:Any], base:SwipeElement?) {
        self.script = script
        self.name = script["id"] as? String

        let origin = base?.frame.origin ?? CGPoint.zero
        let size = base?.frame.size ?? CGSize(width: 100, height: 100)
        self.frame = CGRect(x: SwipeParser.asCGFloat(script["x"]) ?? origin.x,
                       y: SwipeParser.asCGFloat(script["y"]) ?? origin.y,
                       width: SwipeParser.asCGFloat(script["w"]) ?? size.width,
                       height: SwipeParser.asCGFloat(script["h"]) ?? size.height)

        self.backgroundColor = SwipeParser.parseColor(script["backgroundColor"]) ?? base?.backgroundColor
        self.foregroundColor = SwipeParser.parseColor(script["foregroundColor"]) ?? base?.foregroundColor
        self.fillColor = SwipeParser.parseColor(script["fillColor"]) ?? base?.fillColor
        self.strokeColor = SwipeParser.parseColor(script["strokeColor"]) ?? base?.strokeColor
        self.lineWidth = script["lineWidth"] as? CGFloat ?? base?.lineWidth
        self.cornerRadius = SwipeParser.asCGFloat(script["cornerRadius"]) ?? base?.cornerRadius
        self.opacity = SwipeParser.asCGFloat(script["opacity"]) ?? base?.opacity
        if let points = SwipeParser.asCGFloats(script["anchorPoint"]), points.count == 2 {
            self.anchorPoint = CGPoint(x: points[0], y: points[1])
        } else {
            self.anchorPoint = base?.anchorPoint
        }
        
        var xf = CATransform3DIdentity
        var inheritXf = true
        if let rot = SwipeParser.asCGFloat(script["rotate"]) {
            xf = CATransform3DRotate(xf, rot * CGFloat(CGFloat.pi / 180.0), 0, 0, 1)
            inheritXf = false
        } else if let rots = SwipeParser.asCGFloats(script["rotate"]), rots.count == 3 {
            xf.m34 = -1.0/500; // add the perspective
            let m = CGFloat(CGFloat.pi / 180.0) // LATER: static
            xf = CATransform3DRotate(xf, rots[0] * m, 1, 0, 0)
            xf = CATransform3DRotate(xf, rots[1] * m, 0, 1, 0)
            xf = CATransform3DRotate(xf, rots[2] * m, 0, 0, 1)
            inheritXf = false
        }
        self.xf = inheritXf ? base?.xf ?? xf : xf
        
        if let imageName = script["img"] as? String {
            self.image = NSImage(named: imageName)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        } else {
            self.image = nil
        }
        //
        // NOTE: In order to eliminate unnecessary computation, we don't inherit path prop
        // from the base element.
        // As the side-effect, the path animation will happen at the different frame in reverse mode.
        //
        self.path = SwipePath.parse(script["path"]) // NOTE: no inheritance

        // nested elements
        let elementScripts = script["elements"] as? [[String:Any]] ?? []
        var ids = [String]()
        var elements:[String:SwipeElement] = base?.subElements ?? [:]
        for elementScript in elementScripts {
            if let id = elementScript["id"] as? String {
                ids.append(id)
                elements[id] = SwipeElement(elementScript, base:base?.subElements[id])
            }
        }
        self.subElementIds = base?.subElementIds ?? ids
        self.subElements = elements
    }
    
    func apply(to layer:CALayer, duration:Double) {
        layer.transform = CATransform3DIdentity
        layer.frame = frame
        if let backgroundColor = self.backgroundColor {
            layer.backgroundColor = backgroundColor
        }
        if let textLayer = layer as? CATextLayer {
            if let color = foregroundColor {
                textLayer.foregroundColor = color
            }
        } else if let shapeLayer = layer as? CAShapeLayer {
            if let path = path {
                // path has no implicit animation
                let ani = CABasicAnimation(keyPath: "path")
                ani.fromValue = shapeLayer.path
                ani.toValue = path
                ani.beginTime = 0
                ani.duration = duration
                ani.fillMode = .both
                shapeLayer.add(ani, forKey: "path")
                shapeLayer.path = path
            }
            if let color = fillColor {
                shapeLayer.fillColor = color
            }
            if let color = strokeColor {
                shapeLayer.strokeColor = color
            }
            if let width = lineWidth {
                shapeLayer.lineWidth = width
            }
        }
        layer.cornerRadius = cornerRadius ?? 0
        layer.opacity = Float(opacity ?? 1.0)
        layer.anchorPoint = anchorPoint ?? CGPoint(x: 0.5, y: 0.5)
        layer.transform = xf
        if let filterInfo = script["filter"] as? [String:Any],
           let params = filterInfo["params"] as? [String:Any] {
            for (key, value) in params {
                layer.setValue(value, forKeyPath: "filters.f0.\(key)")
            }
        }
        for sublayer in layer.sublayers ?? [] {
            if let name = sublayer.name,
               let element = subElements[name] {
                element.apply(to: sublayer, duration:duration)
            }
        }
    }
}


struct SwipeElement_Previews: PreviewProvider {
    static var previews: some View {
        SwipeFileView("Shapes")
    }
}
