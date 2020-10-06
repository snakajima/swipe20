//
//  SwipeCanvas.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 10/3/20.
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

public struct SwipeCanvas: View {
    @ObservedObject var model = SwipeCanvasModel(scene:SwipeScene(s_script))
    public var body: some View {
        return VStack(spacing:1) {
            SwipeSceneList(model: model)
            GeometryReader { geometry in
                ZStack {
                    SwipeView(scene: model.scene, frameIndex: $model.frameIndex)
                    if let _ = model.selectedElement {
                        SwipeCursor(model:model, geometry:geometry)
                    }
                }.gesture(DragGesture(minimumDistance: 0).onChanged { value in
                    if !model.isDragging {
                        var startLocation = value.startLocation
                        startLocation.y = geometry.size.height - startLocation.y
                        model.selectedElement = model.scene.hitTest(point: startLocation, frameIndex: model.frameIndex)
                        model.isDragging = true
                    }
                    if let element = model.selectedElement {
                        var frame = element.frame
                        frame.origin.x += value.location.x - value.startLocation.x
                        frame.origin.y -= value.location.y - value.startLocation.y
                        frame.origin.y = geometry.size.height - frame.origin.y - frame.height
                        model.cursorRect = frame
                    }
                }.onEnded({ value in
                    var rect = model.cursorRect
                    rect.origin.y = geometry.size.height - rect.origin.y - rect.height
                    model.updateElemen(frame: rect)
                    model.isDragging = false
                }))
            }
        }
    }
}

struct SwipeCanvas_Previews: PreviewProvider {
    static var previews: some View {
        SwipeCanvas()
    }
}

