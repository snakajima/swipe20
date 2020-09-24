//
//  SwipeCALayer.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/24/20.
//
import Cocoa

struct SwipeCALayer {
    let scene:SwipeScene
    init(scene:SwipeScene) {
        self.scene = scene
    }
    
    func makeLayer() -> CALayer {
        let layer = CALayer()
        
        if let color = scene.backgroundColor {
            layer.backgroundColor = color
        }
        if let frame = scene.frames.first {
            layer.sublayers = frame.ids.map {
                frame.elements[$0]!.makeLayer()
            }
        }
        return layer
    }

    func apply(frameIndex:Int, to layer:CALayer?, lastIndex:Int?, disableActions:Bool = false) {
        scene.apply(frameIndex: frameIndex, to: layer, lastIndex: lastIndex, disableActions: disableActions)
    }
}
