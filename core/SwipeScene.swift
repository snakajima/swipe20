//
//  SwipeScene.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import Cocoa

struct SwipeScene {
    private let frames:[SwipeFrame]
    private let backgroundColor:CGColor?
    private let duration:Double
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
    
    func apply(frameIndex:Int, to layer:CALayer?, lastIndex:Int?, disableActions:Bool = false) {
        guard frameIndex >= 0 && frameIndex < frames.count else {
            return
        }
        guard let layer = layer,
              let sublayers = layer.sublayers else {
            return
        }
        
        let frame = frames[frameIndex]
        var duration = frame.duration
        if let lastIndex = lastIndex, lastIndex > frameIndex {
            duration = frames[lastIndex].duration
        }
        CATransaction.begin()
        
        if disableActions {
            CATransaction.setAnimationDuration(1.0)
            CATransaction.setDisableActions(true)
        } else {
            CATransaction.setAnimationDuration(duration ?? self.duration)
        }
        
        frame.apply(to:sublayers, duration:duration ?? self.duration)
        
        // NOTE: implemente delay later
        // layer.beginTime = CACurrentMediaTime() + 1.0
        // layer.fillMode = .backwards
        CATransaction.commit()
    }
    
    func apply(timeOffset:Double, to layer:CALayer?) {
        guard let layer = layer,
              let sublayers = layer.sublayers else {
            return
        }
        for sublayer in sublayers {
            sublayer.timeOffset = timeOffset
        }
    }
    
    func name(ofFrameAtIndex frameIndex:Int) -> String {
        guard frameIndex >= 0 && frameIndex < frames.count else {
            return "N/A"
        }
        let frame = frames[frameIndex]
        return frame.name ?? "frame #\(frameIndex)"
    }
}
