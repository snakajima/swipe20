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

extension SwipeScene {
    func makeLayer() -> CALayer {
        let layer = CALayer()
        if let color = self.backgroundColor {
            layer.backgroundColor = color
        }
        return layer
    }
}

extension SwipeElement {
    func makeLayerRaw() -> CALayer {
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
        return layer
    }
}
