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
    init(_ script:[String:Any]) {
        self.script = script
    }
    
    func makeLayer() -> CALayer {
        let layer = CALayer()
        layer.frame = CGRect(x: SwipeParser.asCGFloat(script, "x"),
                             y: SwipeParser.asCGFloat(script, "y"),
                             width: SwipeParser.asCGFloat(script, "w", 100),
                             height: SwipeParser.asCGFloat(script, "h", 100))
        layer.backgroundColor = NSColor.red.cgColor
        return layer
    }
}

