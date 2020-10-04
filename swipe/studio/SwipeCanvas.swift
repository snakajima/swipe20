//
//  SwipeCanvas.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 10/3/20.
//

import SwiftUI

private let s_script:[String:Any] = [
    "backgroundColor":"#FFFFCC",
    "animation": [
        "engine":"swipe"
    ],
    "frames":[[
        "elements":[[
            "id":"id0",
            "text":"Hello World",
            "foregroundColor":"gray",
            "x":200, "y":0, "w":300, "h":80,
        ],[
            "id":"id1",
            "img":"pngwave.png",
            "x":20, "y":20, "w":180, "h":180,
            "anchorPoint":[0.5,0]
        ],[
            "id":"id2",
            "x":220, "y":100, "w":80, "h":80,
            "backgroundColor":"red",
            "cornerRadius": 20
        ]]
    ]]
]

public struct SwipeCanvas: View {
    @State var frameIndex = 0
    @State var scene = SwipeScene(s_script)
    @State var selectedElement:SwipeElement?
    public var body: some View {
        return GeometryReader { geometry in
            ZStack {
                SwipeView(scene: scene, frameIndex: $frameIndex)
            }.gesture(DragGesture().onChanged { value in
                var startLocation = value.startLocation
                startLocation.y = geometry.size.height - startLocation.y
                if selectedElement == nil {
                    selectedElement = scene.hitTest(point: startLocation, frameIndex: frameIndex)
                    print("onBegan")
                }
                if let element = selectedElement {
                    var location = value.location
                    location.y = geometry.size.height - location.y
                    var frame = element.frame
                    
                    let dx = location.x - startLocation.x
                    let dy = location.y - startLocation.y
                    print(dx, dy, frame.origin.x)
                    
                    frame.origin.x += location.x - startLocation.x
                    frame.origin.y += location.y - startLocation.y
                    let updatedElement = element.updated(frame: frame)
                    if let updatedScene = scene.updated(element: updatedElement, frameIndex: frameIndex) {
                        self.scene = updatedScene
                    }
                }
            }.onEnded({ value in
                self.selectedElement = nil
            }))
        }
    }
}

struct SwipeCanvas_Previews: PreviewProvider {
    static var previews: some View {
        SwipeCanvas()
    }
}
