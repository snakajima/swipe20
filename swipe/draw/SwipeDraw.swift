//
//  SwipeDraw.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/7/20.
//

import SwiftUI

struct SwipeDraw: View {
    @State var currentStroke = SwipeStroke()
    @State var isDragging = false
    @State var location = CGPoint.zero
    @State var strokes = [SwipeStroke]()

    var body: some View {
        let drag = DragGesture(minimumDistance: 0.1)
            .onChanged({ value in
                self.isDragging = true
                self.location = value.location
                self.currentStroke.points.append(value.location)
            })
            .onEnded({ value in
                self.isDragging = false
                strokes.append(currentStroke)
                currentStroke = SwipeStroke()
            })
        ZStack {
            ForEach(strokes) { stroke in
                Path {
                    stroke.append(to: &$0)
                }
                .stroke(style:self.markerStyle)
                .fill(self.markerColor)
            }
            Path {
                self.currentStroke.append(to: &$0)
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

