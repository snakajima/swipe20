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

