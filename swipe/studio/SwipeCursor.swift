//
//  SwipeCursor.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 10/6/20.
//

import SwiftUI

struct SwipeCursor: View {
    @ObservedObject var model:SwipeCanvasModel
    var geometry:GeometryProxy
    
    func resizeGesture(geometry:GeometryProxy, sx:CGFloat?, sy:CGFloat?) -> some Gesture {
        return DragGesture().onChanged() { value in
            let center = model.cursorCenter
            let d0 = center.distance(value.startLocation)
            let d1 = center.distance(value.location)
            let scale = d1 / d0
            model.scale = CGPoint(x: sx ?? scale , y: sy ?? scale)
        }.onEnded() { value in
            var rect = model.scaledCursor
            rect.origin.y = geometry.size.height - rect.origin.y - rect.height
            model.updateElemen(frame: rect)
            model.cursorRect = model.scaledCursor
            model.scale = CGPoint(x: 1, y: 1)
        }
    }
    
    func rotateGesture(geometry:GeometryProxy) -> some Gesture {
        return DragGesture().onChanged() { value in
            let center = model.cursorCenter
            let a0 = center.angle(value.startLocation.applying(model.cursorTransform.inverted()))
            let a1 = center.angle(value.location)
            model.rotZ = a0 - a1
        }.onEnded() { value in
            model.updateElement(rotZ: model.rotZ)
            model.rotZ = 0
        }
    }
    
    var body: some View {
        Group {
            Path(model.cursorPath)
            .stroke(lineWidth: 1.0)
            .foregroundColor(.blue)
            if !model.isDragging {
                let rect = model.scaledCursor
                let center = model.cursorCenter
                Rectangle()
                    .frame(width:14, height:14)
                    .position(CGPoint(x: rect.maxX, y: rect.maxY))
                    .foregroundColor(.blue)
                    .gesture(resizeGesture(geometry: geometry, sx:nil, sy:nil))
                Rectangle()
                    .frame(width:14, height:14)
                    .position(CGPoint(x: center.x, y: rect.maxY))
                    .foregroundColor(.blue)
                    .gesture(resizeGesture(geometry: geometry, sx:1, sy:nil))
                Rectangle()
                    .frame(width:14, height:14)
                    .position(CGPoint(x: rect.maxX, y: center.y))
                    .foregroundColor(.blue)
                    .gesture(resizeGesture(geometry: geometry, sx:nil, sy:1))
                Circle()
                    .frame(width:14, height:14)
                    .position(CGPoint(x: center.x, y: rect.minY))
                    .foregroundColor(.blue)
                    .gesture(rotateGesture(geometry: geometry))
            }
        }.transformEffect(model.cursorTransform)
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

