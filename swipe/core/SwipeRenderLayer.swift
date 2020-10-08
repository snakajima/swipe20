//
//  SwipeRenderLayer.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/24/20.
//
import QuartzCore

/// Protocol to control animatable elements
public protocol SwipeRenderLayer: NSObjectProtocol {
    var frame:CGRect { get set }
    var opacity:Float { get set }
    var transform:CATransform3D { get set }
    var anchorPoint:CGPoint { get set }
}


