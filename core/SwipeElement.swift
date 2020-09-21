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
    let name:String?
    init(_ script:[String:Any], base:SwipeElement?) {
        self.script = script
        let origin = base?.frame.origin ?? CGPoint.zero
        let size = base?.frame.size ?? CGSize(width: 100, height: 100)
        frame = CGRect(x: SwipeParser.asCGFloat(script["x"], origin.x),
                       y: SwipeParser.asCGFloat(script["y"], origin.y),
                       width: SwipeParser.asCGFloat(script["w"], size.width),
                       height: SwipeParser.asCGFloat(script["h"], size.height))
        backgroundColor = SwipeParser.parseColor(script["bg"]) ?? base?.backgroundColor
        name = script["id"] as? String
    }
    
    func makeLayer() -> CALayer {
        let layer = CALayer()
        layer.name = name
        return apply(to: layer)
    }
    
    func apply(to layer:CALayer) -> CALayer {
        layer.frame = frame
        if let backgroundColor = self.backgroundColor {
            layer.backgroundColor = backgroundColor
        }
        
        return layer
    }
}

