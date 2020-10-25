//
//  SwipePreview.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 10/4/20.
//
import SwiftUI

#if os(macOS)
public struct SwipePreview: NSViewRepresentable {
    let scene:SwipeScene
    let scale:CGFloat
    let frameIndex: Int
    
    public init(scene:SwipeScene, scale:CGFloat, frameIndex:Int) {
        self.scene = scene
        self.scale = scale
        self.frameIndex = frameIndex
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self, scene:scene)
    }
    
    public func makeNSView(context: Context) -> some NSView {
        let nsView = FlippedView()
        let layer = CALayer()
        let swipeLayer = context.coordinator.makeLayer()
        swipeLayer.transform = CATransform3DMakeScale(scale, scale, 1.0)
        layer.addSublayer(swipeLayer)
        nsView.layer = layer
        return nsView
    }
    
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        if let layer = nsView.layer,
           let swipeLayer = layer.sublayers?.first {
            context.coordinator.move(scene:scene, to: frameIndex, layer:swipeLayer)
            // HACK: Work-around
            layer.backgroundColor = swipeLayer.backgroundColor
        }
    }

    public class Coordinator: NSObject {
        let view: SwipePreview
        var renderer:SwipeCALayer
        
        init(_ view: SwipePreview, scene:SwipeScene) {
            self.view = view
            self.renderer = SwipeCALayer(scene: scene)
        }
        
        func makeLayer() -> CALayer {
            renderer.makeLayer()
        }
        
        func move(scene:SwipeScene, to frameIndex:Int, layer:CALayer?) {
            if scene.uuid != renderer.scene.uuid {
                self.renderer = SwipeCALayer(scene: scene)
            }
            renderer.apply(frameIndex: frameIndex, to: layer, lastIndex:nil, updateFrameIndex: { _ in })
        }
    }
}
#endif
