//
//  SwipeScene.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//

import Foundation
import Cocoa

struct SwipeScene {
    private let frames:[SwipeFrame]
    private let backgroundColor:CGColor?
    var frameCount:Int { frames.count }
    
    init(_ script:[String:Any]?) {
        let scriptFrames = script?["frames"] as? [[String:Any]] ?? []
        var base:SwipeFrame? = nil
        self.frames = scriptFrames.map {
            let frame = SwipeFrame($0, base:base)
            base = frame
            return frame
        }
        
        backgroundColor = SwipeParser.parseColor(script?["backgroundColor"])
    }
    
    func makeLayer() -> CALayer {
        let layer = CALayer()
        if let color = self.backgroundColor {
            layer.backgroundColor = color
        }
        if let frame = frames.first {
            layer.sublayers = frame.makeLayers()
        }
        return layer
    }
    
    func apply(frameIndex:Int, to layer:CALayer?) {
        guard frameIndex >= 0 && frameIndex < frames.count else {
            return
        }
        guard let layers = layer?.sublayers else {
            return
        }
        let frame = frames[frameIndex]
        frame.apply(to:layers)
    }
}
