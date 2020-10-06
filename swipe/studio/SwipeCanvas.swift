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
    @Published var scale = CGPoint(x: 1, y: 1)
    @Published var isDragging = false
    @Published var scene:SwipeScene
    init(scene:SwipeScene) {
        self.scene = scene
    }

    var cursorCenter:CGPoint {
        CGPoint(x: cursorRect.origin.x + cursorRect.width / 2,
                y: cursorRect.origin.y + cursorRect.height / 2)
    }
    
    var scaledCursor:CGRect {
        let center = cursorCenter
        var xf = CGAffineTransform(translationX: center.x, y: center.y)
        xf = xf.scaledBy(x: scale.x, y: scale.y)
        xf = xf.translatedBy(x: -center.x, y: -center.y)
        return cursorRect.applying(xf)
    }
    
    func updateElementFrame(frame:CGRect) {
        if let element = selectedElement {
           let updatedElement = element.updated(frame: frame)
            scene = scene.updated(element: updatedElement, frameIndex: frameIndex)
        }
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
                        frame.origin.y = geometry.size.height - frame.origin.y - frame.height
                        model.cursorRect = frame
                    }
                }.onEnded({ value in
                    var rect = model.cursorRect
                    rect.origin.y = geometry.size.height - rect.origin.y - rect.height
                    model.updateElementFrame(frame: rect)
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

struct SwipeCursor: View {
    @ObservedObject var model = SwipeCanvasModel(scene:SwipeScene(s_script))
    var geometry:GeometryProxy
    
    func dragGesture(geometry:GeometryProxy) -> _EndedGesture<_ChangedGesture<DragGesture>> {
        return DragGesture().onChanged() { value in
            let center = model.cursorCenter
            let d0 = center.distance(value.startLocation)
            let d1 = center.distance(value.location)
            let scale = d1 / d0
            model.scale = CGPoint(x: scale, y: scale)
        }.onEnded() { value in
            var rect = model.scaledCursor
            rect.origin.y = geometry.size.height - rect.origin.y - rect.height
            model.updateElementFrame(frame: rect)
            model.cursorRect = model.scaledCursor
            model.scale = CGPoint(x: 1, y: 1)
        }
    }
    var body: some View {
        Group {
            let rect = model.scaledCursor
            Path() { path in
                path.addRect(rect)
            }
            .stroke(lineWidth: 1.0)
            .foregroundColor(.blue)
            if !model.isDragging {
                Rectangle()
                    .frame(width:10, height:10)
                    .position(CGPoint(x: rect.maxX, y: rect.maxY))
                    .foregroundColor(.blue)
                    .gesture(dragGesture(geometry: geometry))
            }
        }
    }
}

private extension CGPoint {
    func distance(_ to:CGPoint) -> CGFloat {
        let dx = to.x - x
        let dy = to.y - y
        return sqrt(dx * dx + dy * dy)
    }
}
