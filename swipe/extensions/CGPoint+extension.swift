//
//  CGPoint+extension.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/29/20.
//

import QuartzCore

extension CGPoint {
    func distance(_ to:CGPoint) -> CGFloat {
        return vector(to).distance
    }
    
    func angle(_ to:CGPoint) -> CGFloat {
        return vector(to).angle
    }
    
    func vector(_ to: CGPoint) -> CGVector {
        return CGVector(dx: to.x - x, dy: to.y - y)
    }
}

