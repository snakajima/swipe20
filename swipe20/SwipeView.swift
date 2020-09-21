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
        nsView.layer = CALayer()
        return nsView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        if let layer = nsView.layer {
            layer.backgroundColor = NSColor.yellow.cgColor
        }
        //
    }

    class Coordinator: NSObject {
        let view: SwipeView
        init(_ view: SwipeView) {
            self.view = view
        }
    }
}

private let s_script1 = [
    "scene":[
        "elements":[[
            "text":"Hello World",
            "x":0, "y":0, "w":100, "h":100
        ],[
            "text":"Hello World 2",
            "x":0, "y":100, "w":100, "h":100
        ]]
    ]
]
struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeView(s_script1)
    }
}
