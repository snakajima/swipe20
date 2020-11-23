//
//  SwipeView.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import SwiftUI

#if os(macOS)
typealias OSViewRepresentable = NSViewRepresentable
#else
typealias OSViewRepresentable = UIViewRepresentable
#endif

#if os(macOS)
class FlippedView : NSView {
    override var isFlipped: Bool { true }
}
#endif

public struct SwipeView: OSViewRepresentable {
    public struct Snapshot {
        let frameIndex: Int
        let ratio: Double
        let callback: (CALayer) -> Void
    }
    let scene: SwipeScene
    @Binding var frameIndex: Int
    let scale: CGFloat
    let snapshot: Snapshot?
    
    public init(scene: SwipeScene, frameIndex: Binding<Int>, scale: CGFloat, snapshot: Snapshot? = nil) {
        // print("SwipeView init", scale)
        self.scene = scene
        self._frameIndex = frameIndex
        self.scale = scale
        self.snapshot = snapshot
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self, scene:scene)
    }
    
    #if os(macOS)
    public func makeNSView(context: Context) -> some NSView {
        let layer = CALayer()
        let swipeLayer = context.coordinator.makeLayer(scene:scene)
        swipeLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        layer.addSublayer(swipeLayer)

        let nsView = FlippedView()
        nsView.layer = layer
        return nsView
    }
    
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        if let layer = nsView.layer,
           let swipeLayer = layer.sublayers?[0] {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            swipeLayer.transform = CATransform3DMakeScale(scale, scale, 1)
            CATransaction.commit()
            context.coordinator.apply(scene:scene, at: frameIndex, layer:swipeLayer)
        }
    }
    #else
    public func makeUIView(context: Context) -> some UIView {
        let swipeLayer = context.coordinator.makeLayer(scene:scene)
        let uiView = UIView()
        uiView.layer.addSublayer(swipeLayer)
        return uiView
    }
    
    public func updateUIView(_ nsView: UIViewType, context: Context) {
        //print("SwipeView updateUIView")
        let layer = nsView.layer
        if let swipeLayer = layer.sublayers?[0] {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            swipeLayer.transform = CATransform3DMakeScale(scale, scale, 1)
            CATransaction.commit()
            context.coordinator.apply(scene:scene, at: frameIndex, layer:swipeLayer, snapshot:snapshot)
        }
    }
    #endif
    

    public class Coordinator: NSObject {
        let view: SwipeView
        var renderer:SwipeCALayer
        private var lastIndex:Int? = nil
        
        init(_ view: SwipeView, scene:SwipeScene) {
            self.view = view
            self.renderer = SwipeCALayer(scene: scene)
        }
        
        func makeLayer(scene:SwipeScene) -> CALayer {
            renderer.makeLayer()
        }
        
        func apply(scene:SwipeScene, at frameIndex:Int, layer:CALayer, snapshot:Snapshot?) {
            if let snapshot = snapshot {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                if snapshot.ratio == 0.0 {
                    renderer.apply(frameIndex: snapshot.frameIndex, to: layer, lastIndex: nil, base: nil) { _ in // do nothing
                    }
                } else {
                    let base = scene.frames[snapshot.frameIndex]
                    let frame = scene.frames[snapshot.frameIndex + 1]
                    frame.apply(to: layer.sublayers ?? [], ratio: snapshot.ratio, transition: .next, base: base)
                }
                CATransaction.commit()
                snapshot.callback(layer.superlayer!)
                return
            }
            
            var base:SwipeScene? = nil
            if scene.id != renderer.scene.id {
                let oldIDCount = renderer.scene.frames.first?.ids.count
                base = renderer.scene
                self.renderer.scene = scene
                self.lastIndex = nil
                if oldIDCount != scene.frames.first?.ids.count {
                    print("SwipeView call makeSublalers", oldIDCount ?? -1, scene.frames.first?.ids.count ?? -1)
                    base = nil
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    renderer.makeSublayers(layer: layer)
                    CATransaction.commit()
                }
            }
            renderer.apply(frameIndex: frameIndex, to: layer, lastIndex:lastIndex, base:base, updateFrameIndex: { newIndex in
                    self.view.frameIndex = newIndex
            })
            lastIndex = frameIndex
        }
    }
}

let s_script1:[String:Any] = [
    "backgroundColor":"#FFFFCC",
    "frames":[[
        "elements":[[
            "id":"id0",
            "text":"Hello World",
            "foregroundColor":"gray",
            "x":200, "y":0, "w":300, "h":80,
        ],[
            "id":"id1",
            "x":220, "y":100, "w":80, "h":80,
            "backgroundColor":"red",
            "cornerRadius": 20
        ]]
    ]]
]

struct SwipeView_Previews: PreviewProvider {
    static let s_scene = SwipeScene(s_script1)
    @State static var frameIndex = 0
    static var previews: some View {
        VStack {
            SwipeView(scene:s_scene, frameIndex:$frameIndex, scale:1.0)
        }
    }
}
