//
//  SwipePage.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//

import Foundation
import Cocoa

struct SwipePage {
    let ids:[String]
    let elements:[String:SwipePageElement]
    init(_ script:[String:Any]) {
        print("SwipePage", script)
        let elementScripts = script["elements"] as? [[String:Any]] ?? [[String:Any]]()

        var ids = [String]()
        var elements = [String:SwipePageElement]()
        for elementScript in elementScripts {
            if let id = elementScript["id"] as? String {
                ids.append(id)
                elements[id] = SwipePageElement(elementScript)
            }
        }
        self.ids = ids
        self.elements = elements
    }
    
}

struct SwipePageElement {
    let script:[String:Any]
    init(_ script:[String:Any]) {
        self.script = script
        print("SwipePageElement", script)
    }

    func apply(layer:CALayer) {
        let frame = layer.frame
        layer.frame = CGRect(x: SwipeParser.asCGFloat(script, "x", frame.origin.x),
                             y: SwipeParser.asCGFloat(script, "y", frame.origin.y),
                             width: SwipeParser.asCGFloat(script, "w", frame.width),
                             height: SwipeParser.asCGFloat(script, "h", frame.height))

    }
}
