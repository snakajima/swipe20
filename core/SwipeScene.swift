//
//  SwipeScene.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import Cocoa

struct SwipeScene {
    let frames:[SwipeFrame]
    let backgroundColor:CGColor?
    let duration:Double
    var frameCount:Int { frames.count }
    
    init(_ script:[String:Any]?) {
        let scriptFrames = script?["frames"] as? [[String:Any]] ?? []
        var base:SwipeFrame? = nil
        self.frames = scriptFrames.map {
            let frame = SwipeFrame($0, base:base)
            base = frame
            return frame
        }
        
        self.duration = script?["duration"] as? Double ?? 0.25 // same as system default
        backgroundColor = SwipeParser.parseColor(script?["backgroundColor"])
    }
    
    /*
    func apply(timeOffset:Double, to layer:CALayer?) {
        guard let layer = layer,
              let sublayers = layer.sublayers else {
            return
        }
        for sublayer in sublayers {
            sublayer.timeOffset = timeOffset
        }
    }
    */
    
    func name(ofFrameAtIndex frameIndex:Int) -> String {
        guard frameIndex >= 0 && frameIndex < frames.count else {
            return "N/A"
        }
        let frame = frames[frameIndex]
        return frame.name ?? "frame #\(frameIndex)"
    }
}
