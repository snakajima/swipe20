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
    init(_ script:[String:Any]) {
        self.script = script
        frame = CGRect(x: SwipeParser.asCGFloat(script, "x"),
                       y: SwipeParser.asCGFloat(script, "y"),
                       width: SwipeParser.asCGFloat(script, "w", 100),
                       height: SwipeParser.asCGFloat(script, "h", 100))
        name = script["id"] as? String
    }
    
    func makeLayer() -> CALayer {
        let layer = CALayer()
        layer.frame = frame
        layer.backgroundColor = NSColor.red.cgColor
        layer.name = name
        return layer
    }
}

