//
//  SwipeAnimation.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/24/20.
//
import QuartzCore

class SwipeAnimation {
    enum Style {
        case normal
        case gravity
    }
    
    let duration:Double
    var beginTime:CFTimeInterval = 0
    init(duration:Double) {
        self.duration = duration
    }
    
    func start(callback:@escaping (Double)->Void) {
        beginTime = CACurrentMediaTime()
        tick(callback: callback)
    }
    
    func tick(callback:@escaping (Double)->Void) {
        let delta = CACurrentMediaTime() - beginTime
        if delta > duration {
            callback(1.0)
            return
        }
        callback(delta / duration)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1/60) {
            self.tick(callback: callback)
        }
    }
}
