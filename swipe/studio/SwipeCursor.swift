//
//  SwipeCursor.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 10/6/20.
//

import SwiftUI

struct SwipeCursor: View {
    @ObservedObject var model:SwipeCanvasModel
    let scale:CGFloat
    let selectionColor:Color
    var geometry:GeometryProxy
    
    func resizeGesture(geometry:GeometryProxy, sx:CGFloat?, sy:CGFloat?) -> some Gesture {
        return DragGesture().onChanged() { value in
            let center = scaled(point:model.cursorCenter)
            let v0 = center.vector(value.startLocation)
            let v1 = center.vector(value.location)
            let scale = v1.distance / v0.distance
            model.scale = CGPoint(x: sx ?? (v0.dx * v1.dx > 0 ? scale : -scale) , y: sy ?? (v0.dy * v1.dy > 0 ? scale : -scale))
        }.onEnded() { value in
            print("scale", model.scale)
            model.updateElement(frame: model.scaledCursor, flipX: model.scale.x < 0, flipY: model.scale.y < 0)
            model.cursorRect = model.scaledCursor
            model.scale = CGPoint(x: 1, y: 1)
        }
    }
    
    func rotateGesture(geometry:GeometryProxy) -> some Gesture {
        return DragGesture().onChanged() { value in
            let center = scaled(point:model.cursorCenter)
            let a1 = center.angle(value.location.applying(model.cursorTransform(center: center)))
            model.rotZ = .pi + a1 + (model.selectedElement?.rotZ ?? 0)
        }.onEnded() { value in
            model.updateElement(rotZ: model.rotZ)
            model.rotZ = 0
        }
    }
    
    func scaled(point:CGPoint) -> CGPoint {
        return CGPoint(x: point.x * scale, y: point.y * scale)
    }
    
    func scaledCursor() -> CGRect {
        var rect = model.scaledCursor
        rect.origin = scaled(point:rect.origin)
        rect.size.width *= scale
        rect.size.height *= scale
        return rect
    }
    
    var body: some View {
        let center = scaled(point:model.cursorCenter)
        return ZStack {
            let rect = scaledCursor()
            Path(CGPath(rect: rect, transform: nil))
            .stroke(lineWidth: 1.0)
            .foregroundColor(selectionColor)
            if !model.isDragging {
                Rectangle()
                    .frame(width:14, height:14)
                    .position(CGPoint(x: rect.maxX, y: rect.maxY))
                    .foregroundColor(selectionColor)
                    .gesture(resizeGesture(geometry: geometry, sx:nil, sy:nil))
                Rectangle()
                    .frame(width:14, height:14)
                    .position(CGPoint(x: center.x, y: rect.maxY))
                    .foregroundColor(selectionColor)
                    .gesture(resizeGesture(geometry: geometry, sx:1, sy:nil))
                Rectangle()
                    .frame(width:14, height:14)
                    .position(CGPoint(x: rect.maxX, y: center.y))
                    .foregroundColor(selectionColor)
                    .gesture(resizeGesture(geometry: geometry, sx:nil, sy:1))
                Circle()
                    .frame(width:14, height:14)
                    .position(CGPoint(x: center.x, y: rect.minY))
                    .foregroundColor(selectionColor)
                    .gesture(rotateGesture(geometry: geometry))
            }
        }
        .transformEffect(model.cursorTransform(center: center))
        .contentShape(Rectangle())
    }
}

