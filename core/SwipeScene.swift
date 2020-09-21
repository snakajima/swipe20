//
//  SwipeScene.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//

import Foundation
import Cocoa

struct SwipeScene {
    let elements:[SwipeElement]
    init(_ script:[String:Any]?) {
        guard let script = script,
              let elements = script["elements"] as? [[String:Any]] else {
            self.elements = []
            return
        }
        self.elements = elements.map {
            SwipeElement($0)
        }
    }
    
    func makeLayers() -> [CALayer] {
        return elements.map { $0.makeLayer() }
    }
}
