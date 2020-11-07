//
//  SwipeDraw.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/7/20.
//

import SwiftUI

class SwipeDrawModel: ObservableObject {
    @Published var currentStroke = SwipeStroke()
    @Published var isDragging = false
    @Published var location = CGPoint.zero
    @Published var strokes = [SwipeStroke]()
}

struct SwipeDraw: View {
    @ObservedObject var model = SwipeDrawModel()
    
    var body: some View {
        let drag = DragGesture(minimumDistance: 0.1)
            .onChanged({ value in
                model.isDragging = true
                model.location = value.location
                model.currentStroke.points.append(value.location)
            })
            .onEnded({ value in
                model.isDragging = false
                model.strokes.append(model.currentStroke)
                model.currentStroke = SwipeStroke()
            })
        ZStack {
            ForEach(model.strokes) { stroke in
                Path {
                    stroke.append(to: &$0)
                }
                .stroke(style:self.markerStyle)
                .fill(self.markerColor)
            }
            Path {
                model.currentStroke.append(to: &$0)
            }
            .stroke(style:self.markerStyle)
            .fill(self.markerColor)
            .background(Color(white: 1.0, opacity: 0.1))
            .gesture(drag)
        }
    }
    
    let markerStyle = StrokeStyle(lineWidth: 3.0, lineCap: CGLineCap.round, lineJoin: CGLineJoin.round, miterLimit: 0.1, dash: [], dashPhase: 0)
    let markerColor = Color(.blue)
}


struct Canvas_Previews: PreviewProvider {
    static var previews: some View {
        Canvas_Instance()
    }
}

struct Canvas_Instance: View {
    var body: some View {
        VStack(alignment: .center) {
            SwipeDraw()
                .edgesIgnoringSafeArea(.all)
        }
    }
}

