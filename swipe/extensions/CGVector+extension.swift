//
//  CGVector+extension.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/29/20.
//

import QuartzCore

extension CGVector {
    var distance:CGFloat {
        return sqrt(dx * dx + dy * dy)
    }
    
    var angle:CGFloat {
        return atan2(dx, dy)
    }
}
