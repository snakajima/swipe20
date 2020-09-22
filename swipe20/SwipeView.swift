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
        init(_ view: SwipeView) {
            self.view = view
        }
        
        func move(to frameIndex:Int, layer:CALayer?) {
            view.scene.apply(frameIndex: frameIndex, to: layer)
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
            "x":300, "y":10,
        ],[
            "id":"id1",
            "x":220, "y":100, "w":120, "h":60,
            "cornerRadius": 20,
        ],[
            "id":"id2",
            "x":10, "y":200, "w":200, "h":200,
        ]]
    ],[
        "elements":[[
            "id":"id0",
            "foregroundColor":"black",
            "x":300, "y":110,
        ],[
            "id":"id1",
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
            "id":"id0",
            "rotate":30,
        ],[
            "id":"id2",
            "x":100, "y":200, "w":200, "h":200,
        ]]
    ]]
]

let s_scene = SwipeScene(s_script1)

struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SwipeView(scene:s_scene, frameIndex:0)
        }
    }
}
