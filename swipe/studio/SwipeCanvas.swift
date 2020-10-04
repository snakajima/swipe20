//
//  SwipeCanvas.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 10/3/20.
//

import SwiftUI

private let s_script:[String:Any] = [
    "backgroundColor":"#FFFFCC",
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
    public var body: some View {
        return GeometryReader { geometry in
            ZStack {
                SwipeView(scene: scene, frameIndex: $frameIndex)
            }.gesture(DragGesture().onEnded { value in
                var location = value.location
                location.y = geometry.size.height - location.y
                var startLocation = value.startLocation
                startLocation.y = geometry.size.height - startLocation.y

                if let element = scene.hitTest(point: startLocation, frameIndex: frameIndex) {
                    print("tap", element.id)
                    var frame = element.frame
                    frame.origin.x += location.x - startLocation.x
                    frame.origin.y += location.y - startLocation.y
                    let updatedElement = element.updated(frame: frame)
                    if let updatedScene = scene.updated(element: updatedElement, frameIndex: frameIndex) {
                        self.scene = updatedScene
                    }
                }
            })
        }
    }
}

struct SwipeCanvas_Previews: PreviewProvider {
    static var previews: some View {
        SwipeCanvas()
    }
}
