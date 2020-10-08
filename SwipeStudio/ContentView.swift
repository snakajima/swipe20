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
            "x":200, "y":0, "w":300, "h":80,
            "animation": [
                "style":"summersault"
            ],
        ],[
            "id":"id1",
            "img":"pngwave.png",
            "x":20, "y":20, "w":180, "h":180,
            "anchorPoint":[0.5,0],
            "animation": [
                "style":"jump"
            ],
        ],[
            "id":"id2",
            "x":220, "y":100, "w":80, "h":80,
            "backgroundColor":"red",
            "cornerRadius": 20,
            "animation": [
                "style":"leap"
            ],
        ],[
            "id":"id3",
            "x":220, "y":200, "w":80, "h":80,
            "img":"pngwave.png",
            "rotate": 60,
        ]]
    ]]
]

struct ContentView: View {
    var body: some View {
        SwipeCanvas(model:SwipeCanvasModel(scene:SwipeScene(s_script)))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
