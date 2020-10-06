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
        ]]
    ]]
]

class SwipeCanvasModel: ObservableObject {
    @Published var frameIndex = 0 {
        didSet {
            selectedElement = nil
        }
    }
    @Published var selectedElement:SwipeElement?
    @Published var cursorRect:CGRect = .zero
    @Published var isDragging = false
    @Published var scene:SwipeScene
    init(scene:SwipeScene) {
        self.scene = scene
    }
}

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
                        model.cursorRect = frame
                    }
                }.onEnded({ value in
                    if let element = model.selectedElement {
                        let updatedElement = element.updated(frame: model.cursorRect)
                        model.scene = model.scene.updated(element: updatedElement, frameIndex: model.frameIndex)
                    }
                    model.isDragging = false
                }))
            }
        }
    }
}

struct SwipeSceneList: View {
    @ObservedObject var model:SwipeCanvasModel
    var body: some View {
        ScrollView (.horizontal, showsIndicators: true) {
            HStack(spacing:1) {
                ForEach(0..<model.scene.frameCount, id:\.self) { index in
                    SwipeSceneItem(model:model, index: index)
                }
            }.frame(height:120)
        }
    }
}

struct SwipeSceneItem: View {
    @ObservedObject var model:SwipeCanvasModel
    let index:Int
    var body: some View {
        HStack(spacing:1) {
            VStack(spacing:1) {
                ZStack {
                    SwipePreview(scene: model.scene, scale:0.2, frameIndex: index)
                    if index == model.frameIndex {
                        Rectangle()
                            .stroke(lineWidth: 1.0)
                            .foregroundColor(.blue)
                    }
                }
                .frame(width:180)
                .gesture(TapGesture().onEnded() {
                    model.frameIndex = index
                })
                HStack(spacing:4) {
                    Button(action: {
                        model.scene = model.scene.frameDeleted(atIndex: index)
                    }) {
                        SwipeSymbol.trash.frame(width:20, height:20)
                    }.disabled(model.scene.frameCount == 1)
                    Spacer()
                    Button(action: {
                        print("star")
                    }) {
                        SwipeSymbol.gearshape.frame(width:20, height:20)
                    }
                }
            }
            Button(action:{
                model.scene = model.scene.frameDuplicated(atIndex: index)
                model.frameIndex = index + 1
            }) {
                SwipeSymbol.plus.frame(width:20, height:20)
            }
        }
    }
}

struct SwipeCanvas_Previews: PreviewProvider {
    static var previews: some View {
        SwipeCanvas()
    }
}


struct SwipeCursor: View {
    @ObservedObject var model = SwipeCanvasModel(scene:SwipeScene(s_script))
    var geometry:GeometryProxy
    var body: some View {
        Group {
                var frame = model.cursorRect
                Path() { path in
                    frame.origin.y = geometry.size.height - frame.origin.y - frame.height
                    path.addRect(frame)
                }
                .stroke(lineWidth: 1.0)
                .foregroundColor(.blue)
        }
    }
}
