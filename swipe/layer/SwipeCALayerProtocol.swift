//
//  SwipeCALayerProtocol.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/25/20.
//

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

public protocol SwipeCALayerProtocol {
    func makeLayer() -> CALayer
    func apply(frameIndex:Int, to layer:CALayer?, lastIndex:Int?, updateFrameIndex:@escaping (Int)->Void)
}

