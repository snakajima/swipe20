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
    let name:String?
    init(_ script:[String:Any], base:SwipeElement?) {
        self.script = script
        let origin = base?.frame.origin ?? CGPoint.zero
        let size = base?.frame.size ?? CGSize(width: 100, height: 100)
        frame = CGRect(x: SwipeParser.asCGFloat(script, "x", origin.x),
                       y: SwipeParser.asCGFloat(script, "y", origin.y),
                       width: SwipeParser.asCGFloat(script, "w", size.width),
                       height: SwipeParser.asCGFloat(script, "h", size.height))
        name = script["id"] as? String
    }
    
    func makeLayer() -> CALayer {
        return apply(layer: CALayer())
    }
    
    func apply(layer:CALayer) -> CALayer {
        layer.frame = frame
        layer.backgroundColor = NSColor.red.cgColor
        layer.name = name
        return layer
    }
}

