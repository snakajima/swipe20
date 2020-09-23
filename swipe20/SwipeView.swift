//
//  SwipeView.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import SwiftUI

struct SwipeView: NSViewRepresentable {
    let scene:SwipeScene
    var frameIndex: Int
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeNSView(context: Context) -> some NSView {
        let nsView = NSView()
        nsView.layer = scene.makeLayer()
        return nsView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        context.coordinator.move(to: frameIndex, layer:nsView.layer)
    }

    class Coordinator: NSObject {
        let view: SwipeView
        private var lastIndex:Int? = nil
        
        init(_ view: SwipeView) {
            self.view = view
        }
        
        func move(to frameIndex:Int, layer:CALayer?) {
            view.scene.apply(frameIndex: frameIndex, to: layer, lastIndex:lastIndex)
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
