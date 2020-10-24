//
//  ContentView.swift
//  SwipeStudio
//
//  Created by SATOSHI NAKAJIMA on 10/4/20.
//

import SwiftUI

private let s_script:[String:Any] = [
    "backgroundColor":"#FFFFCC",
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

struct ContentView: View {
    let scene = SwipeScene(s_script)
    var body: some View {
        SwipeCanvas(model:SwipeCanvasModel(scene:scene), scale: 0.5)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
