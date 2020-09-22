//
//  SwipeView.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//

import Foundation
import SwiftUI

struct SwipeView: NSViewRepresentable {
    let scene:SwipeScene
    var frameIndex: Int
    /*
    init(scene:SwipeScene) {
        self.scene = scene
    }
    */
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeNSView(context: Context) -> some NSView {
        print("makeNSView called")
        let nsView = NSView()
        nsView.layer = scene.makeLayer()
        return nsView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        print("updateNSView called \(frameIndex)")
        context.coordinator.move(to: frameIndex, layer:nsView.layer)
    }

    class Coordinator: NSObject {
        let view: SwipeView
        init(_ view: SwipeView) {
            self.view = view
        }
        
        func move(to frameIndex:Int, layer:CALayer?) {
            view.scene.apply(frameIndex: frameIndex, to: layer)
        }
    }
}

let s_script1:[String:Any] = [
    "frames":[[
        "elements":[[
            "id":"id0",
            "text":"Hello World",
            "x":200, "y":0, "w":80, "h":80,
            "backgroundColor":"green"
        ],[
            "id":"id1",
            "x":220, "y":100, "w":80, "h":80,
            "backgroundColor":"red"
        ],[
            "id":"id2",
            "x":10, "y":300, "w":100, "h":100,
            "img":"kodim03.png",
            "cornerRadius": 20
        ]]
    ],[
        "elements":[[
            "id":"id0",
            "x":300, "y":10, "w":80, "h":80
        ],[
            "id":"id1",
            "x":220, "y":100, "w":120, "h":60,
            "cornerRadius": 20
        ],[
            "id":"id2",
            "x":10, "y":200, "w":200, "h":200,
        ]]
    ],[
        "elements":[[
            "id":"id0",
            "x":300, "y":110, "w":80, "h":80,
            "backgroundColor":"blue"
        ]]
    ],[
        "elements":[[
            "id":"id1",
            "x":220, "y":200, "w":120, "h":60,
            "rotate":90
        ]]
    ],[
        "elements":[[
            "id":"id2",
            "x":100, "y":200, "w":200, "h":200,
        ]]
    ]]
]
struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SwipeView(scene:scene, frameIndex: 0)
        }
    }
}
