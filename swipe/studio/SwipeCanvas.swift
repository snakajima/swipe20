//
//  SwipeCanvas.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 10/3/20.
//

import SwiftUI

public struct SwipeCanvas: View {
    @ObservedObject var model: SwipeCanvasModel
    let scale = CGFloat(0.5)
    public var body: some View {
        return VStack(spacing:1) {
            SwipeSceneList(model: model)
            GeometryReader { geometry in
                ZStack {
                    SwipeView(scene: model.scene, frameIndex: $model.frameIndex, scale:scale)
                    if let _ = model.selectedElement {
                        SwipeCursor(model:model, scale:scale, geometry:geometry)
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
                    model.updateElement(frame: rect)
                    model.isDragging = false
                }))
            }
        }
    }
}

private let s_script:[String:Any] = [
    "backgroundColor":"#FFFFCC",
    "duration": Double(1.0),
    "animation": [
        "engine":"swipe"
    ],
    "frames":[[
        "elements":[[
            "id":"id0",
            "x":220, "y":200, "w":80, "h":80,
            "img":"pngwave.png"
        ]]
    ]]
]

struct SwipeCanvas_Previews: PreviewProvider {
    static var previews: some View {
        SwipeCanvas(model:SwipeCanvasModel(scene:SwipeScene(s_script)))
    }
}

