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
        let layer = scene.makeLayer()
        if let frame = scene.firstFrame {
            layer.sublayers = frame.ids.map {
                frame.elements[$0]!.makeLayer()
            }
        }
        layer.speed = 0
        return layer
    }

    func apply(frameIndex:Int, to layer:CALayer?, lastIndex:Int?, updateFrameIndex:@escaping (Int)->Void) {
        guard let frame = scene.frameAt(index: frameIndex),
              let layer = layer,
              let sublayers = layer.sublayers else {
            return
        }

        let transition = SwipeTransition.eval(from: lastIndex, to: frameIndex)
        if transition == .same {
            return
        }
        
        var duration = transition == .initial ? 1e-10 : frame.duration
        if transition == .prev {
            duration = scene.frameAt(index:lastIndex!)?.duration
        }
        
        let animation = SwipeAnimation(duration: duration ?? scene.duration)
        animation.start { (ratio) in
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            frame.apply(to:sublayers, ratio:ratio, transition: transition, base:scene.frameAt(index: lastIndex))
            CATransaction.commit()
            
            if ratio == 1.0 && frameIndex < scene.frameCount - 1 && transition != .prev {
                switch(scene.playMode) {
                case .auto, 
                     .cont where transition != .initial:
                        self.apply(frameIndex: frameIndex + 1, to: layer, lastIndex: frameIndex, updateFrameIndex: updateFrameIndex)
                        updateFrameIndex(frameIndex + 1)
                    default:
                        break
                }
            }
        }
    }
}

private extension SwipeFrame {
    func apply(to layers:[CALayer], ratio:Double, transition:SwipeTransition, base:SwipeFrame?) {
        for layer in layers {
            guard let name = layer.name,
                  let element = elements[name] else {
                return
            }
            element.apply(to: layer, ratio:ratio, transition: transition, base:base?.elements[name])
        }
    }
}

private extension SwipeElement {
    func apply(to layer:CALayer, ratio:Double, transition:SwipeTransition, base:SwipeElement?) {
        if transition == .prev, let base = base {
            base.apply(target: layer, ratio: 1 - ratio, from: self)
        } else {
            self.apply(target: layer, ratio: ratio, from: base)
        }
        for sublayer in layer.sublayers ?? [] {
            if let name = sublayer.name,
               let element = subElements[name] {
                element.apply(to: sublayer, ratio:ratio, transition: transition, base:base?.subElements[name])
            }
        }
    }
    
    func makeLayer() -> CALayer {
        let layer = makeLayerRaw()
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
        layer.opacity = Float(opacity)
        layer.anchorPoint = anchorPoint

        var xf = CATransform3DIdentity
        xf.m34 = -1.0/500; // add the perspective
        let m = CGFloat(CGFloat.pi / 180.0) // LATER: static
        xf = CATransform3DRotate(xf, rotX * m, 1, 0, 0)
        xf = CATransform3DRotate(xf, rotY * m, 0, 1, 0)
        xf = CATransform3DRotate(xf, rotZ * m, 0, 0, 1)
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
    }
}

extension CALayer: SwipeRenderLayer {
    public var id: Any? {
        get {
            return self.contents
        }
        set {
            self.contents = newValue
        }
    }
}
