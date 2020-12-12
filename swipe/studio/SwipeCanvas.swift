//
//  SwipeCanvas.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 10/3/20.
//

import SwiftUI

let s_scriptEmpty:[String:Any] = [
    "duration": Double(0.7),
    "backgroundColor": "black",
    "animation": [
        "engine":"swipe"
    ],
    "frames":[[
        "elements":[[
        ]]
    ]]
]

let s_scriptGen:[String:Any] = ["dimension": [1920.0, 1080.0], "frames": [["elements": [["w": 180.0, "id": "id0", "x": 20.0, "cornerRadius": 20.0, "backgroundColor": [1.0, 0.0, 0.0, 1.0] as [CGFloat], "h": 180.0, "y": 500.0, "animation": ["style": "leap"]]]]], "animation": ["engine": "swipe"], "duration": 0.7]

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

public struct SwipeCanvasHolder: View {
    let sceneObject: SceneObject
    let previewHeight: CGFloat
    public var body: some View {
        SwipeCanvas(sceneObject: sceneObject, previewHeight: previewHeight)
    }
}

public struct SwipeCanvas: View {
    @ObservedObject var model: SwipeCanvasModel
    @ObservedObject var drawModel = SwipeDrawModel()
    let previewHeight:CGFloat
    let selectionColor = Color(Color.RGBColorSpace.sRGB, red: 0.0, green: 1.0, blue: 1.0, opacity: 1.0)
    @State var snapshot: SwipeView.Snapshot? = nil
    
    init(sceneObject:SceneObject, previewHeight:CGFloat) {
        let script = try? JSONSerialization.jsonObject(with: sceneObject.script!, options: [])
        let scene = SwipeScene(script as? [String:Any], uuid: sceneObject.uuid)
        self.model = SwipeCanvasModel(scene:scene)
        self.previewHeight = previewHeight
        self.drawModel.delegate = self.model
    }

    func scaled(_ point:CGPoint, scale:CGFloat) -> CGPoint {
        return CGPoint(x: point.x / scale, y: point.y / scale)
    }

    public var body: some View {
        return VStack(spacing:1) {
            SwipeSceneList(model: model, previewHeight: previewHeight,
                           selectionColor: selectionColor, snapshot:$snapshot)
            ZStack {
                VStack {
                    GeometryReader { geometry in
                        let scale:CGFloat = geometry.size.height / model.scene.dimension.height
                        ZStack {
                            SwipeView(scene: model.scene, frameIndex: $model.frameIndex, scale:scale, snapshot: snapshot)
                            if let _ = model.selectedElement {
                                SwipeCursor(model:model, scale:scale, selectionColor:selectionColor, geometry:geometry)
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
                                model.updateElement(frame: model.cursorRect, flipX: false, flipY: false)
                            }
                            model.isDragging = false
                            model.isSelecting = false
                        }))
                    }
                    HStack {
                        Button(action: {
                            model.undo()
                        }) {
                            SwipeSymbol.backward.frame(width:32, height:32)
                                .foregroundColor(model.undoable ? .accentColor: .gray)
                        }
                        .disabled(!model.undoable)
                        Button(action: {
                            model.redo()
                        }) {
                            SwipeSymbol.forward.frame(width:32, height:32)
                                .foregroundColor(model.redoable ? .accentColor: .gray)
                        }
                        .disabled(!model.redoable)
                        Spacer()
                        Button(action: {
                            model.selectedElement = nil
                            drawModel.activate()
                        }, label: {
                            SwipeSymbol.scribble.frame(width:32, height:32)
                                .foregroundColor(.accentColor)
                        })
                    }
                    .frame(height:32, alignment: .bottom)
                }
                if drawModel.isActive {
                    SwipeDraw(model: drawModel, dimension: model.scene.dimension)
                }
            }
        }
        .background(Color(.sRGB, red: 1.0, green: 1.0, blue: 0.8, opacity: 1.0))
        .navigationBarTitleDisplayMode(.inline)
    }
}

/*
struct SwipeCanvas_Previews: PreviewProvider {
    static var previews: some View {
            let drawModel = SwipeDrawModel()
            SwipeCanvas(model:SwipeCanvasModel(scene:SwipeScene(s_scriptSample)), drawModel:drawModel, previewHeight: 150,
                        selectionColor: .accentColor, buttonColor: .accentColor)
        }
}
*/
