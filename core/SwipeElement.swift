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
        layer.frame = CGRect(x: script["x"] as? CGFloat ?? 0,
                             y: script["y"] as? CGFloat ?? 0,
                             width: script["w"] as? CGFloat ?? 100,
                             height: script["h"] as? CGFloat ?? 100)
        layer.backgroundColor = NSColor.red.cgColor
        return layer
    }
}
