//
//  SwipeDraw.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/7/20.
//

import SwiftUI

struct SwipeDraw: View {
    @ObservedObject var model = SwipeDrawModel()
    
    var body: some View {
        let drag = DragGesture(minimumDistance: 0.1)
            .onChanged({ value in
                model.onChanged(location: value.location)
            })
            .onEnded({ value in
                model.onEnded(location: value.location)
            })
        VStack {
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
            HStack {
                Button(action: {
                    model.undo()
                }) {
                    SwipeSymbol.backward.frame(width:24, height:24)
                        .foregroundColor(model.undoable ? .blue: .gray)
                }
                .disabled(!model.undoable)
                Button(action: {
                    model.redo()
                }) {
                    SwipeSymbol.forward.frame(width:24, height:24)
                        .foregroundColor(model.redoable ? .blue: .gray)
                }
                .disabled(!model.redoable)
                Spacer()
            }
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

