//
//  SwipeCALayer.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/24/20.
//
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

public struct SwipeCALayer {
    var scene:SwipeScene
    let useSwipeAnimation:Bool
    init(scene:SwipeScene) {
        self.scene = scene
        if let engine = scene.animation?["engine"] as? String, engine == "swipe" {
            self.useSwipeAnimation = true
        } else {
            self.useSwipeAnimation = false
        }
    }
    
    public func makeLayer() -> CALayer {
        let layer = scene.makeLayer()
        makeSublayers(layer: layer)
        if useSwipeAnimation {
            layer.speed = 0
        }
        return layer
    }
    
    public func makeSublayers(layer:CALayer) {
        if let frame = scene.firstFrame {
            layer.sublayers = frame.ids.map {
                frame.elements[$0]!.makeLayer()
            }
        }
    }

    public func apply(frameIndex:Int, to layer:CALayer?, lastIndex:Int?, base:SwipeScene?, updateFrameIndex:@escaping (Int)->Void) {
        //print("SwipeCALayer apply")
        guard let frame = scene.frameAt(index: frameIndex),
              let layer = layer,
              let sublayers = layer.sublayers else {
            return
        }

        let transition = SwipeTransition.eval(from: lastIndex, to: frameIndex)
        if transition == .same {
            return
        }
        
        var duration = frame.duration
        if transition == .prev {
            duration = scene.frameAt(index:lastIndex!)?.duration
        }
        
        if (useSwipeAnimation) {
            func apply(ratio:Double) {
                //print("SwipeCALayer applyRatio", ratio)
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                frame.apply(to:sublayers, ratio:ratio, transition: transition, base:base?.frameAt(index:frameIndex) ?? scene.frameAt(index: lastIndex))
                CATransaction.commit()
                
                if ratio == 1.0 && frameIndex < scene.frameCount - 1 && transition != .prev {
                    switch(scene.playMode) {
                    case .auto,
                         .cont where transition != .initial:
                        self.apply(frameIndex: frameIndex + 1, to: layer, lastIndex: frameIndex, base:nil, updateFrameIndex: updateFrameIndex)
                            updateFrameIndex(frameIndex + 1)
                    default:
                        break
                    }
                }
            }
            if lastIndex == nil && base == nil {
                apply(ratio: 1.0)
            } else {
                let animation = SwipeAnimation(duration: duration ?? scene.duration)
                animation.start(callback: apply)
            }
        } else {
            CATransaction.begin()
            CATransaction.setAnimationDuration(duration ?? scene.duration)
            frame.prepare(layers:sublayers, duration:duration ?? scene.duration, transition: transition, base:base?.frameAt(index:frameIndex) ?? scene.frameAt(index: lastIndex))
            CATransaction.commit()
        }
    }
    
}

private extension SwipeScene {
    func makeLayer() -> CALayer {
        let layer = CALayer()
        layer.anchorPoint = .zero
        layer.frame = CGRect(origin: .zero, size: dimension)
        layer.backgroundColor = self.backgroundColor ?? CGColor(red: 1, green: 1, blue: 1.0, alpha: 1)
        return layer
    }
}

private extension SwipeFrame {
    // This method will be called only once when we use Core Animation
    func prepare(layers:[CALayer], duration:Double,  transition:SwipeTransition, base:SwipeFrame?) {
        //print("SwipeFrame prepare")
        for layer in layers {
            guard let name = layer.name,
                  let element = elements[name] else {
                return
            }
            element.prepare(layer: layer, duration:duration, transition: transition, base:base?.elements[name])
        }
    }

    // This method will be called multiple times when we use Swipe Animation
    func apply(to layers:[CALayer], ratio:Double, transition:SwipeTransition, base:SwipeFrame?) {
        for layer in layers {
            guard let name = layer.name,
                  let element = elements[name] else {
                print("#Error: SwipeCALayer no element for name", layer.name ?? "n/a")
                return
            }
            //print("SwipeFrame applyToLayer", ratio, name)
            element.apply(to: layer, ratio:ratio, transition: transition, base:base?.elements[name])
        }
    }
}

private extension SwipeElement {
    // NOTE: We do not support the animation of "text" or "image" property itself. 
    func makeLayer() -> CALayer {
        //print("SwipeElement makeLayer", id)
        let layer:CALayer
        if let text = self.text {
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
                layer.contentsGravity = .resize
                layer.masksToBounds = true
            }
        }
        
        if let filterInfo = self.filter,
           let filterName = filterInfo["name"] as? String {
            if let filter = CIFilter(name: filterName) {
                filter.name = "f0"
                layer.filters = [filter]
            }
        }
        layer.name = id

        layer.sublayers = subElementIds.map {
            subElements[$0]!.makeLayer()
        }
        
        prepare(layer:layer, duration:1e-10, transition: .initial, base:nil)
        return layer
    }

    // This method will be called multiple times when we use Swipe Animation
    func apply(to layer:CALayer, ratio:Double, transition:SwipeTransition, base:SwipeElement?) {
        if transition == .prev, let base = base {
            base.apply(target: layer, ratio: 1 - ratio, from: self, element:self)
        } else {
            self.apply(target: layer, ratio: ratio, from: base, element:self)
        }
        for sublayer in layer.sublayers ?? [] {
            if let name = sublayer.name,
               let element = subElements[name] {
                element.apply(to: sublayer, ratio:ratio, transition: transition, base:base?.subElements[name])
            }
        }
    }

    func prepare(layer:CALayer, duration:Double,  transition:SwipeTransition, base:SwipeElement?) {
        //print("SwipeElement prepare", id)
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
            shapeLayer.lineCap = .round
            shapeLayer.lineJoin = .round
            shapeLayer.miterLimit = 0.1
        }
        layer.cornerRadius = cornerRadius ?? 0
        layer.opacity = Float(opacity)
        layer.anchorPoint = anchorPoint

        var xf = CATransform3DIdentity
        xf.m34 = -1.0/500; // add the perspective
        xf = CATransform3DRotate(xf, rotX, 1, 0, 0)
        xf = CATransform3DRotate(xf, rotY, 0, 1, 0)
        xf = CATransform3DRotate(xf, rotZ, 0, 0, 1)
        layer.transform = xf

        if let filterInfo = self.filter,
           let params = filterInfo["params"] as? [String:Any] {
            for (key, value) in params {
                layer.setValue(value, forKeyPath: "filters.f0.\(key)")
            }
        }
        for sublayer in layer.sublayers ?? [] {
            if let name = sublayer.name,
               let element = subElements[name] {
                element.prepare(layer: sublayer, duration:duration, transition: transition, base:base?.subElements[name])
            }
        }
    }
}

extension CALayer: SwipeRenderLayer {
    /*
    public var id: Any? {
        get {
            return self.contents
        }
        set {
            self.contents = newValue
        }
    }
     */
}
