//
//  SwipeScene.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//

import Foundation
import Cocoa

struct SwipeScene {
    let frames:[SwipeFrame]
    init(_ script:[String:Any]?) {
        let scriptFrames = script?["frames"] as? [[String:Any]] ?? [[String:Any]]()
        self.frames = scriptFrames.map {
            SwipeFrame($0)
        }
    }
    
    func makeLayers() -> [CALayer] {
        guard let frame = frames.first else {
            return []
        }
        return frame.makeLayers()
    }
    
    func apply(index:Int, to layers:[CALayer]) {
        guard index < frames.count else {
            return
        }
        let frame = frames[index]
        frame.apply(to:layers)
    }
}
