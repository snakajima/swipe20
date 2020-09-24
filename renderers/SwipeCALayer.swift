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
        guard frameIndex >= 0 && frameIndex < scene.frames.count else {
            return
        }
        guard let layer = layer,
              let sublayers = layer.sublayers else {
            return
        }
        
        let frame = scene.frames[frameIndex]
        var duration = frame.duration
        if let lastIndex = lastIndex, lastIndex > frameIndex {
            duration = scene.frames[lastIndex].duration
        }
        CATransaction.begin()
        
        if disableActions {
            CATransaction.setAnimationDuration(1.0)
            CATransaction.setDisableActions(true)
        } else {
            CATransaction.setAnimationDuration(duration ?? scene.duration)
        }
        
        frame.apply(to:sublayers, duration:duration ?? scene.duration)
        
        // NOTE: implemente delay later
        // layer.beginTime = CACurrentMediaTime() + 1.0
        // layer.fillMode = .backwards
        CATransaction.commit()
    }
    
}

extension SwipeElement {
    func makeLayer(disableActions:Bool = false) -> CALayer {
        let layer:CALayer
        if let text = script["text"] as? String {
            let textLayer = CATextLayer()
            textLayer.string = text
            layer = textLayer
        } else if let _ = self.path {
            let shapeLayer = CAShapeLayer()
            layer = shapeLayer
        } else {
            layer = CALayer()
            if let image = self.image {
                layer.contents = image
                layer.contentsGravity = .resizeAspectFill
                layer.masksToBounds = true
            }
        }
        
        if let filterInfo = script["filter"] as? [String:Any],
           let filterName = filterInfo["name"] as? String {
            if let filter = CIFilter(name: filterName) {
                filter.name = "f0"
                layer.filters = [filter]
            }
        }
        layer.name = name
        layer.sublayers = subElementIds.map {
            subElements[$0]!.makeLayer()
        }
        
        if disableActions {
            layer.beginTime = 0
            layer.speed = 0
            layer.fillMode = .forwards
        }

        apply(to: layer, duration:1e-10)
        return layer
    }
}
