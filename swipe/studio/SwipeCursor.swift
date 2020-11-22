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
            let d0 = center.distance(value.startLocation)
            let d1 = center.distance(value.location)
            let scale = d1 / d0
            model.scale = CGPoint(x: sx ?? scale , y: sy ?? scale)
        }.onEnded() { value in
            model.updateElement(frame: model.scaledCursor)
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

private extension CGPoint {
    func distance(_ to:CGPoint) -> CGFloat {
        let dx = to.x - x
        let dy = to.y - y
        return sqrt(dx * dx + dy * dy)
    }
    
    func angle(_ to:CGPoint) -> CGFloat {
        let dx = to.x - x
        let dy = to.y - y
        return atan2(dx, dy)
    }
}

