//
//  SwipeScene.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

public enum SwipeTransition {
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
public struct SwipeScene {
    /// It controls the auto-play behavior
    enum PlayMode :String {
        /// It does not auto-play
        case none = "none"
        /// It automatically starts playing to the end
        case auto = "auto"
        /// Once started, it plays to the end
        case cont = "continue"
    }
    
    private(set) var frames:[SwipeFrame]
    let dimension:CGSize
    let backgroundColor:CGColor?
    let duration:Double
    let playMode:PlayMode
    let animation:[String:Any]?
    var uuid = UUID()
    var frameCount:Int { frames.count }
    var firstFrame:SwipeFrame? { frames.first }

    /// Initializes a scene with specified description (in Swipe script)
    public init(_ script:[String:Any]?) {
        self.animation = script?["animation"] as? [String:Any]
        let scriptFrames = script?["frames"] as? [[String:Any]] ?? []
        var base:SwipeFrame? = nil
        
        if let dimension = SwipeParser.asCGFloats(script?["dimension"]),
           dimension.count == 2 {
            self.dimension = CGSize(width: dimension[0], height: dimension[1])
        } else {
            self.dimension = CGSize(width: 1920, height: 1080)
        }
        
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
    
    func hitTest(point:CGPoint, frameIndex:Int) -> SwipeElement? {
        guard frameIndex >= 0 && frameIndex < frameCount else {
            return nil
        }
        return frames[frameIndex].hitTest(point: point)
    }
    
    func cloned() -> SwipeScene {
        var scene = self
        scene.uuid = UUID()
        return scene
    }

    func updated(element:SwipeElement, frameIndex:Int) -> SwipeScene {
        guard frameIndex >= 0 && frameIndex < frameCount else {
            return self
        }
        var scene = self.cloned()
        scene.frames[frameIndex] = scene.frames[frameIndex].updated(element: element)
        return scene
    }
    
    func frameDuplicated(atIndex frameIndex:Int) -> SwipeScene {
        guard frameIndex >= 0 && frameIndex < frameCount else {
            return self
        }
        var scene = self.cloned()
        var frames = scene.frames
        frames.insert(frames[frameIndex], at: frameIndex)
        scene.frames = frames
        return scene
    }

    func frameDeleted(atIndex frameIndex:Int) -> SwipeScene {
        guard frameIndex >= 0 && frameIndex < frameCount && frameCount > 0 else {
            return self
        }
        var scene = self.cloned()
        var frames = scene.frames
        frames.remove(at: frameIndex)
        scene.frames = frames
        return scene
    }

    var script:[String:Any] {
        var script:[String:Any] = [
            "dimansion":[dimension.width, dimension.height],
            "duration":duration,
        ]
        if let animation = self.animation {
            script["animation"] = animation
        }
        return script
    }
}
