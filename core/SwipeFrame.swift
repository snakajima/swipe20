//
//  SwipePage.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//

import Foundation
import Cocoa

struct SwipeFrame {
    let ids:[String]
    let elements:[String:SwipeElement]
    init(_ script:[String:Any]) {
        print("SwipeFrame", script)
        let elementScripts = script["elements"] as? [[String:Any]] ?? [[String:Any]]()

        var ids = [String]()
        var elements = [String:SwipeElement]()
        var prevElement:SwipeElement?
        for elementScript in elementScripts {
            if let id = elementScript["id"] as? String {
                ids.append(id)
                elements[id] = SwipeElement(elementScript, base:prevElement)
                prevElement = elements[id]
            }
        }
        self.ids = ids
        self.elements = elements
    }
    
    func makeLayers() -> [CALayer] {
        return ids.map {
            elements[$0]!.makeLayer()
        }
    }
}
