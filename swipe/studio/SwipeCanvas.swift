//
//  SwipeCanvas.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 10/3/20.
//

import SwiftUI

public struct SwipeCanvas: View {
    @ObservedObject var model: SwipeCanvasModel
    let previewHeight:CGFloat
    
    init(model:SwipeCanvasModel, previewHeight:CGFloat) {
        self.model = model
        self.previewHeight = previewHeight
    }

    func scaled(_ point:CGPoint, scale:CGFloat) -> CGPoint {
        return CGPoint(x: point.x / scale, y: point.y / scale)
    }

    public var body: some View {
        return VStack(spacing:1) {
            SwipeSceneList(model: model, previewHeight: previewHeight)
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
                Button(action: {}) {
                    SwipeSymbol.backward.frame(width:24, height:24)
                        .foregroundColor(.blue)
                }
                Button(action: {}) {
                    SwipeSymbol.forward.frame(width:24, height:24)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            .frame(height:32, alignment: .bottom)
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

