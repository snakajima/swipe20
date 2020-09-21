//
//  SwipeScene.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//

import Foundation
import Cocoa

struct SwipeScene {
    let ids:[String]
    let elements:[String:SwipeElement]
    init(_ script:[String:Any]?) {
        guard let script = script,
              let elementScripts = script["elements"] as? [[String:Any]] else {
            self.ids = []
            self.elements = [:]
            return
        }
        var ids = [String]()
        var elements = [String:SwipeElement]()
        for elementScript in elementScripts {
            if let id = elementScript["id"] as? String {
                ids.append(id)
                elements[id] = SwipeElement(elementScript)
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
