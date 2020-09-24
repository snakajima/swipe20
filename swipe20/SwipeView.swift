//
//  SwipeView.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import SwiftUI

struct SwipeView: NSViewRepresentable {
    let scene:SwipeScene
    let frameIndex: Int
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, scene:scene)
    }
    
    func makeNSView(context: Context) -> some NSView {
        let nsView = NSView()
        nsView.layer = context.coordinator.makeLayer()
        return nsView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        context.coordinator.move(to: frameIndex, layer:nsView.layer)
    }

    class Coordinator: NSObject {
        let view: SwipeView
        let renderer:SwipeCALayer
        private var lastIndex:Int? = nil
        
        init(_ view: SwipeView, scene:SwipeScene) {
            self.view = view
            self.renderer = SwipeCALayer(scene: scene)
        }
        
        func makeLayer() -> CALayer {
            renderer.makeLayer()
        }
        
        func move(to frameIndex:Int, layer:CALayer?) {
            renderer.apply(frameIndex: frameIndex, to: layer, lastIndex:lastIndex)
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
    static var previews: some View {
        VStack {
            SwipeView(scene:s_scene, frameIndex:0)
        }
    }
}
