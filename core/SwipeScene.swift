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
        
        self.duration = script?["duration"] as? Double ?? 0.2
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
        CATransaction.begin()
        CATransaction.setAnimationDuration(frame.duration ?? duration)
        frame.apply(to:layers)
        CATransaction.commit()
    }
    
    func name(ofFrameAtIndex frameIndex:Int) -> String {
        guard frameIndex >= 0 && frameIndex < frames.count else {
            return "N/A"
        }
        let frame = frames[frameIndex]
        return frame.name ?? "frame #\(frameIndex)"
    }
}
