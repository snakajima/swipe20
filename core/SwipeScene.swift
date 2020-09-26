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

/// A structure that describes a series of frames to be presented animted between
struct SwipeScene {
    /// It controls the auto-play behavior
    enum PlayMode :String {
        /// It does not auto-play
        case none = "none"
        /// It automatically starts playing to the end
        case auto = "auto"
        /// Once started, it plays to the end
        case cont = "continue"
    }
    
    private let frames:[SwipeFrame]
    let backgroundColor:CGColor?
    let duration:Double
    let playMode:PlayMode
    var frameCount:Int { frames.count }
    var firstFrame:SwipeFrame? { frames.first }

    /// Initializes a scene with specified description (in Swipe script)
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
        
        if let mode = script?["playmode"] as? String {
            switch(mode) {
            case PlayMode.auto.rawValue: self.playMode = .auto
            case PlayMode.cont.rawValue: self.playMode = .cont
            default: self.playMode = .none
            }
        } else {
            self.playMode = .none
        }
    }
    
    /// It returns a frame at the specified index
    func frameAt(index:Int?) -> SwipeFrame? {
        guard let index = index,
              index >= 0 && index < frameCount else {
            return nil
        }
        return frames[index]
    }
    
    /// It returns the display name of the frame
    func name(ofFrameAtIndex frameIndex:Int) -> String {
        guard frameIndex >= 0 && frameIndex < frames.count else {
            return "N/A"
        }
        let frame = frames[frameIndex]
        return frame.name ?? "frame #\(frameIndex)"
    }
}
