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
    
    func makeLayer() -> CALayer {
        let layer = CALayer()
        if let frame = frames.first {
            layer.sublayers = frame.makeLayers()
        }
        return layer
    }
    
    func apply(index:Int, to layers:[CALayer]) {
        guard index >= 0 && index < frames.count else {
            return
        }
        let frame = frames[index]
        frame.apply(to:layers)
    }
}
