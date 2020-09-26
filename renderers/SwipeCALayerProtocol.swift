//
//  SwipeCALayerProtocol.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/25/20.
//

import Cocoa

protocol SwipeCALayerProtocol {
    func makeLayer() -> CALayer
    func apply(frameIndex:Int, to layer:CALayer?, lastIndex:Int?, updateFrameIndex:@escaping (Int)->Void)
}
