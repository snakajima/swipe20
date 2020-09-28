//
//  SwipeView.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import SwiftUI

struct SwipeView: NSViewRepresentable {
    let scene:SwipeScene
    @Binding var frameIndex: Int
    let options:[String:Any]?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, scene:scene, options: options)
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
        let renderer:SwipeCALayerProtocol
        private var lastIndex:Int? = nil
        
        init(_ view: SwipeView, scene:SwipeScene, options:[String:Any]?) {
            self.view = view
            if let options = options, let alt = options["alt"] as? Bool, alt == true {
                print("alt")
                self.renderer = SwipeCALayerAlt(scene: scene)
            } else {
                print("normal")
                self.renderer = SwipeCALayer(scene: scene)
            }
        }
        
        func makeLayer() -> CALayer {
            renderer.makeLayer()
        }
        
        func move(to frameIndex:Int, layer:CALayer?) {
            renderer.apply(frameIndex: frameIndex, to: layer, lastIndex:lastIndex, updateFrameIndex: { newIndex in
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
            SwipeView(scene:s_scene, frameIndex:$frameIndex, options: nil)
        }
    }
}
