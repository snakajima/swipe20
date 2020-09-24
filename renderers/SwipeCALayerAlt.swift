//
//  SwipeCALayer.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/24/20.
//
import Cocoa

struct SwipeCALayerAlt: SwipeCALayerProtocol {
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

    func apply(frameIndex:Int, to layer:CALayer?, lastIndex:Int?) {
        guard frameIndex >= 0 && frameIndex < scene.frames.count else {
            return
        }
        guard let layer = layer,
              let sublayers = layer.sublayers else {
            return
        }
        
        let frame = scene.frames[frameIndex]
        var duration = frame.duration
        let transition = SwipeTransition.eval(from: lastIndex, to: frameIndex)
        if transition == .prev {
            duration = scene.frames[lastIndex!].duration
        }
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration ?? scene.duration)
        frame.apply(to:sublayers, duration:duration ?? scene.duration, transition: transition, base:scene.frameAt(index: lastIndex))
        
        // NOTE: implemente delay later
        // layer.beginTime = CACurrentMediaTime() + 1.0
        // layer.fillMode = .backwards
        CATransaction.commit()
        
        let animation = SwipeAnimation(duration: duration ?? scene.duration)
        animation.start()
    }
    
}

private extension SwipeFrame {
    func apply(to layers:[CALayer], duration:Double, transition:SwipeTransition, base:SwipeFrame?) {
        for layer in layers {
            guard let name = layer.name,
                  let element = elements[name] else {
                return
            }
            element.apply(to: layer, duration:duration, transition: transition, base:base?.elements[name])
        }
    }
}

private extension SwipeElement {
    func makeLayer() -> CALayer {
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
        
        apply(to: layer, duration:1e-10, transition: .initial, base:nil)
        return layer
    }

    func apply(to layer:CALayer, duration:Double, transition:SwipeTransition, base:SwipeElement?) {
        layer.transform = CATransform3DIdentity
        layer.frame = frame
        if let backgroundColor = self.backgroundColor {
            layer.backgroundColor = backgroundColor
        }
        if let textLayer = layer as? CATextLayer {
            if let color = foregroundColor {
                textLayer.foregroundColor = color
            }
        } else if let shapeLayer = layer as? CAShapeLayer {
            if let path = path {
                // path has no implicit animation
                let ani = CABasicAnimation(keyPath: "path")
                ani.fromValue = shapeLayer.path
                ani.toValue = path
                ani.beginTime = 0
                ani.duration = duration
                ani.fillMode = .both
                shapeLayer.add(ani, forKey: "path")
                shapeLayer.path = path
            }
            if let color = fillColor {
                shapeLayer.fillColor = color
            }
            if let color = strokeColor {
                shapeLayer.strokeColor = color
            }
            if let width = lineWidth {
                shapeLayer.lineWidth = width
            }
        }
        layer.cornerRadius = cornerRadius ?? 0
        layer.opacity = Float(opacity ?? 1.0)
        layer.anchorPoint = anchorPoint ?? CGPoint(x: 0.5, y: 0.5)
        layer.transform = xf
        if let filterInfo = script["filter"] as? [String:Any],
           let params = filterInfo["params"] as? [String:Any] {
            for (key, value) in params {
                layer.setValue(value, forKeyPath: "filters.f0.\(key)")
            }
        }
        for sublayer in layer.sublayers ?? [] {
            if let name = sublayer.name,
               let element = subElements[name] {
                element.apply(to: sublayer, duration:duration, transition: transition, base:base?.subElements[name])
            }
        }
    }}
