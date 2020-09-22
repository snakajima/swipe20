//
//  SwipeElement.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import Cocoa
import CoreImage

struct SwipeElement {
    private let script:[String:Any]
    private let name:String?
    private let image:CGImage?
    
    private let frame:CGRect
    private let backgroundColor:CGColor?
    private let foregroundColor:CGColor?
    private let cornerRadius:CGFloat?
    private let xf:CATransform3D
    
    init(_ script:[String:Any], base:SwipeElement?) {
        self.script = script
        let origin = base?.frame.origin ?? CGPoint.zero
        let size = base?.frame.size ?? CGSize(width: 100, height: 100)
        frame = CGRect(x: SwipeParser.asCGFloat(script["x"]) ?? origin.x,
                       y: SwipeParser.asCGFloat(script["y"]) ?? origin.y,
                       width: SwipeParser.asCGFloat(script["w"]) ?? size.width,
                       height: SwipeParser.asCGFloat(script["h"]) ?? size.height)
        backgroundColor = SwipeParser.parseColor(script["backgroundColor"]) ?? base?.backgroundColor
        foregroundColor = SwipeParser.parseColor(script["foregroundColor"]) ?? base?.foregroundColor
        cornerRadius = SwipeParser.asCGFloat(script["cornerRadius"]) ?? base?.cornerRadius
        var xf = CATransform3DIdentity
        if let rot = SwipeParser.asCGFloat(script["rotate"]) {
            xf = CATransform3DRotate(xf, rot * CGFloat(CGFloat.pi / 180.0), 0, 0, 1)
        }
        self.xf = xf
        name = script["id"] as? String
        if let imageName = script["img"] as? String {
            self.image = NSImage(named: imageName)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        } else {
            self.image = nil
        }
    }
    
    func makeLayer() -> CALayer {
        let layer:CALayer
        if let text = script["text"] as? String {
            let textLayer = CATextLayer()
            textLayer.string = text
            layer = textLayer
        } else {
            layer = CALayer()
            if let image = self.image {
                layer.contents = image
                layer.contentsGravity = .resizeAspectFill
                layer.masksToBounds = true
            }
        }
        if let filterInfo = script["filter"] as? [String:Any],
           let filterName = filterInfo["name"] as? String {
            if let filter = CIFilter(name: filterName) {
                filter.name = "f0"
                layer.filters = [filter]
            }
        }
        layer.name = name
        return apply(to: layer)
    }
    
    func apply(to layer:CALayer) -> CALayer {
        layer.transform = CATransform3DIdentity
        layer.frame = frame
        if let backgroundColor = self.backgroundColor {
            layer.backgroundColor = backgroundColor
        }
        if let textLayer = layer as? CATextLayer {
            if let color = foregroundColor {
                textLayer.foregroundColor = color
            }
        }
        layer.cornerRadius = cornerRadius ?? 0
        layer.transform = xf
        if let filterInfo = script["filter"] as? [String:Any],
           let params = filterInfo["params"] as? [String:Any] {
            for (key, value) in params {
                print(key, value)
                layer.setValue(value, forKeyPath: "filters.f0.\(key)")
            }
        }

        return layer
    }
}

