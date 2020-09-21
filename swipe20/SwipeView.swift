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
            "x":200, "y":0, "w":80, "h":80
        ],[
            "id":"id2",
            "text":"Hello World 2",
            "x":220, "y":100, "w":80, "h":80
        ]]
    ],[
        "elements":[[
            "id":"id0",
            "x":300, "y":10, "w":80, "h":80
        ],[
            "id":"id2",
            "x":220, "y":100, "w":120, "h":60
        ]]
    ],[
        "elements":[[
            "id":"id0",
            "x":300, "y":110, "w":80, "h":80
        ],[
            "id":"id2",
            "x":220, "y":200, "w":120, "h":60
        ]]
    ]]
]
struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            //let scene = SwipeScene(s_script1)
            //SwipeView(scene:scene)
            Button("Play") {
                print("play")
            }
        }
    }
}
