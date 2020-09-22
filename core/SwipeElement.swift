//
//  SwipeElement.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//

import Foundation
import Cocoa

struct SwipeElement {
    let script:[String:Any]
    let frame:CGRect
    let backgroundColor:CGColor?
    let cornerRadius:CGFloat?
    let name:String?
    let xf:CATransform3D
    init(_ script:[String:Any], base:SwipeElement?) {
        self.script = script
        let origin = base?.frame.origin ?? CGPoint.zero
        let size = base?.frame.size ?? CGSize(width: 100, height: 100)
        frame = CGRect(x: SwipeParser.asCGFloat(script["x"]) ?? origin.x,
                       y: SwipeParser.asCGFloat(script["y"]) ?? origin.y,
                       width: SwipeParser.asCGFloat(script["w"]) ?? size.width,
                       height: SwipeParser.asCGFloat(script["h"]) ?? size.height)
        backgroundColor = SwipeParser.parseColor(script["bg"]) ?? base?.backgroundColor
        cornerRadius = SwipeParser.asCGFloat(script["cornerRadius"]) ?? base?.cornerRadius
        var xf = CATransform3DIdentity
        if let rot = SwipeParser.asCGFloat(script["rotate"]) {
            xf = CATransform3DRotate(xf, rot * CGFloat(CGFloat.pi / 180.0), 0, 0, 1)
        } else {
            xf = base?.xf ?? CATransform3DIdentity
        }
        self.xf = xf
        name = script["id"] as? String
    }
    
    func makeLayer() -> CALayer {
        let layer:CALayer
        if let text = script["text"] as? String {
            let textLayer = CATextLayer()
            textLayer.string = text
            layer = textLayer
        } else {
            layer = CALayer()
        }
        layer.name = name
        return apply(to: layer)
    }
    
    func apply(to layer:CALayer) -> CALayer {
        layer.frame = frame
        if let backgroundColor = self.backgroundColor {
            layer.backgroundColor = backgroundColor
        }
        layer.cornerRadius = cornerRadius ?? 0
        layer.transform = xf
        
        return layer
    }
}

