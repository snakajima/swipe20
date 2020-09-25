//
//  SwipeScene.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import Cocoa

enum SwipeTransition {
    case initial
    case next
    case prev
    case skip
    case same
    
    static func eval(from:Int?, to:Int) -> SwipeTransition {
        guard let from = from else {
            return .initial
        }
        switch(from) {
        case _ where from == to: return .same
        case _ where to == from + 1 : return .next
        case _ where to == from - 1 : return .prev
        default: return .skip
        }
    }
}

struct SwipeScene {
    let frames:[SwipeFrame]
    let backgroundColor:CGColor?
    let duration:Double
    let autoPlay:Bool
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
        self.backgroundColor = SwipeParser.parseColor(script?["backgroundColor"])
        self.autoPlay = script?["autoPlay"] as? Bool ?? false
    }
    
    func frameAt(index:Int?) -> SwipeFrame? {
        guard let index = index else {
            return nil
        }
        return frames[index]
    }
    
    func name(ofFrameAtIndex frameIndex:Int) -> String {
        guard frameIndex >= 0 && frameIndex < frames.count else {
            return "N/A"
        }
        let frame = frames[frameIndex]
        return frame.name ?? "frame #\(frameIndex)"
    }
}
