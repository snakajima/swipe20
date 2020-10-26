//
//  SwipeStudio.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 10/26/20.
//

import SwiftUI

let s_scriptSample:[String:Any] = [
    //"backgroundColor":"#FFFFDD",
    "duration": Double(1.0),
    "animation": [
        "engine":"swipe"
    ],
    "frames":[[
        "elements":[[
            "id":"id0",
            "text":"Hello World",
            "foregroundColor":"gray",
            "x":20, "y":350, "w":300, "h":80,
            "animation": [
                "style":"summersault"
            ],
        ],[
            "id":"id2",
            "x":20, "y":500, "w":180, "h":180,
            "backgroundColor":"red",
            "cornerRadius": 20,
            "animation": [
                "style":"leap"
            ],
        ],[
            "id":"id1",
            "img":"pngwave.png",
            "x":20, "y":500, "w":180, "h":180,
            "anchorPoint":[0.5,0],
            "animation": [
                "style":"jump"
            ],
        ],[
            "id":"id3",
            "x":20, "y":200, "w":150, "h":150,
            "img":"pngwave.png",
            "animation": [
                "style":"bounce"
            ],
        ]]
    ]]
]

public struct SwipeStudio: View {
    
    public var body: some View {
        #if os(macOS)
        let previewHeight:CGFloat = 150
        #else
        let previewHeight:CGFloat = 100
        #endif
        NavigationView {
            let scene = SwipeScene(s_scriptSample)
            let model = SwipeCanvasModel(scene:scene)
#if os(macOS)
            NavigationLink(destination:
                SwipeCanvas(model: model, previewHeight: previewHeight)
            ) {
                Text("Sample")
            }
#else
            NavigationLink(destination:
                SwipeCanvas(model: model, previewHeight: previewHeight)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            Button("Presse Me") {
                                print("pressed", scene.script)
                            }
                        }
                    }
            ) {
                Text("Sample")
            }
#endif
        }
    }
}

struct SwipeStudio_Previews: PreviewProvider {
    static var previews: some View {
        SwipeStudio()
    }
}
