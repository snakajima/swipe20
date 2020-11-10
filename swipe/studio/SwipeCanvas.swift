//
//  SwipeCanvas.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 10/3/20.
//

import SwiftUI

let s_scriptEmpty:[String:Any] = [
    "duration": Double(0.7),
    "animation": [
        "engine":"swipe"
    ],
    "frames":[[
        "elements":[[
        ]]
    ]]
]

let s_scriptSample:[String:Any] = [
    //"backgroundColor":"#FFFFDD",
    "duration": Double(0.7),
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
                "style":"jump"
            ],
        ]]
    ],[
        "elements":[[
            "id":"id1",
            "x":500
        ],[
            "id":"id0",
            "x":120
        ],[
            "id":"id2",
            "x":500,
            "y":800
        ]]
    ]]
]

let s_scriptText:[String:Any] = [
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
        ]]
    ],[
        "elements":[[
            "id":"id0",
            "x":120
        ]]
    ]]
]

public struct SwipeCanvas: View {
    @ObservedObject var model: SwipeCanvasModel
    @ObservedObject var drawModel = SwipeDrawModel()
    let previewHeight:CGFloat
    
    init(model:SwipeCanvasModel, previewHeight:CGFloat) {
        self.model = model
        self.previewHeight = previewHeight
        self.drawModel.delegate = self.model
    }

    func scaled(_ point:CGPoint, scale:CGFloat) -> CGPoint {
        return CGPoint(x: point.x / scale, y: point.y / scale)
    }

    public var body: some View {
        return VStack(spacing:1) {
            SwipeSceneList(model: model, previewHeight: previewHeight)
            ZStack {
                VStack {
                    GeometryReader { geometry in
                        let scale:CGFloat = geometry.size.height / model.scene.dimension.height
                        ZStack {
                            SwipeView(scene: model.scene, frameIndex: $model.frameIndex, scale:scale)
                            if let _ = model.selectedElement {
                                SwipeCursor(model:model, scale:scale, geometry:geometry)
                            }
                        }.gesture(DragGesture(minimumDistance: 0).onChanged { value in
                            if !model.isSelecting {
                                var startLocation = value.startLocation
                                startLocation = scaled(startLocation, scale:scale)
                                model.selectedElement = model.scene.hitTest(point: startLocation, frameIndex: model.frameIndex)
                                model.isSelecting = true
                            } else {
                                model.isDragging = true
                            }
                            if let element = model.selectedElement {
                                var frame = element.frame
                                frame.origin.x += (value.location.x - value.startLocation.x) / scale
                                frame.origin.y += (value.location.y - value.startLocation.y) / scale
                                model.cursorRect = frame
                            }
                        }.onEnded({ value in
                            if model.isDragging {
                                model.updateElement(frame: model.cursorRect)
                            }
                            model.isDragging = false
                            model.isSelecting = false
                        }))
                    }
                    HStack {
                        Button(action: {
                            model.undo()
                        }) {
                            SwipeSymbol.backward.frame(width:24, height:24)
                                .foregroundColor(model.undoable ? .blue: .gray)
                        }
                        .disabled(!model.undoable)
                        Button(action: {
                            model.redo()
                        }) {
                            SwipeSymbol.forward.frame(width:24, height:24)
                                .foregroundColor(model.redoable ? .blue: .gray)
                        }
                        .disabled(!model.redoable)
                        Spacer()
                        Button(action: {
                            model.selectedElement = nil
                            drawModel.activate()
                        }, label: {
                            Text("Pen")
                        })
                    }
                    .frame(height:32, alignment: .bottom)
                }
                if drawModel.isActive {
                    SwipeDraw(model: drawModel)
                }
            }
        }
        .background(Color(.sRGB, red: 1.0, green: 1.0, blue: 0.8, opacity: 1.0))
    }
}

struct SwipeCanvas_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SwipeCanvas(model:SwipeCanvasModel(scene:SwipeScene(s_scriptSample)), previewHeight: 150)
        }
    }
}

