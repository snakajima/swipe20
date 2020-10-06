//
//  SwipeAnimation.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/24/20.
//
import QuartzCore

/// A object that performs simple animations
public class SwipeAnimation {
    /// Specifies the type of animation
    public enum Style: String {
        case normal = "normal"
        case leap = "leap"
        case bounce = "bounce"
        case jump = "jump"
        case summersault = "summersault"
    }
    
    private let duration:Double
    private let frameRate:Double
    private var beginTime:CFTimeInterval = 0

    /// Initializes an animation object with the specified duration
    init(duration:Double, frameRate:Double = 60.0) {
        self.duration = duration
        self.frameRate = frameRate
    }

    /// Starts the animation.
    func start(callback:@escaping (Double)->Void) {
        beginTime = CACurrentMediaTime()
        tick(callback: callback)
    }
    
    private func tick(callback:@escaping (Double)->Void) {
        let delta = CACurrentMediaTime() - beginTime
        if delta > duration {
            callback(1.0)
            return
        }
        callback(delta / duration)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1/frameRate) {
            self.tick(callback: callback)
        }
    }
}
