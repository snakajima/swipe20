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
    let pages:[SwipePage]
    init(_ script:[String:Any]) {
        self.scene = SwipeScene(script["scene"] as? [String:Any])
        let pages = script["pages"] as? [[String:Any]] ?? [[String:Any]]()
        self.pages = pages.map { SwipePage($0) }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeNSView(context: Context) -> some NSView {
        let nsView = NSView()
        let layer = CALayer()
        let layers = scene.makeLayers()
        layers.forEach { layer.addSublayer($0) }
        nsView.layer = layer
        return nsView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        guard let layer = nsView.layer else {
            return
        }
            
        layer.backgroundColor = NSColor.yellow.cgColor
        
    }

    class Coordinator: NSObject {
        let view: SwipeView
        init(_ view: SwipeView) {
            self.view = view
        }
    }
}

let s_script1:[String:Any] = [
    "scene":[
        "elements":[[
            "id":"id0",
            "text":"Hello World",
            "x":200, "y":0, "w":80, "h":80
        ],[
            "id":"id2",
            "text":"Hello World 2",
            "x":220, "y":100, "w":80, "h":80
        ]]
    ],
    "pages":[[
        "elements":[[
            "elements":[[
                "id":"id0",
                "x":300, "y":10, "w":80, "h":80
            ],[
                "id":"id2",
                "x":220, "y":100, "w":120, "h":60
            ]]
        ]]
    ]]
]
struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SwipeView(s_script1)
            Button("Play") {
                print("play")
            }
        }
    }
}
