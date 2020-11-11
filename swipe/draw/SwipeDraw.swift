//
//  SwipeDraw.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/7/20.
//

import SwiftUI

struct SwipeDraw: View {
    @ObservedObject var model:SwipeDrawModel
    let dimension:CGSize
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let scale:CGFloat = geometry.size.height / dimension.height
                let drag = DragGesture(minimumDistance: 0.1)
                    .onChanged { model.onChanged($0.location) }
                    .onEnded { model.onEnded($0.location, scale:scale) }
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
                Button(action: {
                    model.done()
                }, label: {
                    Text("Done")
                })
            }
            .frame(height:32, alignment: .bottom)
            .background(Color(.sRGB, red: 1.0, green: 1.0, blue: 0.8, opacity: 1.0))
        }
    }
    
    let markerStyle = StrokeStyle(lineWidth: 3.0, lineCap: CGLineCap.round, lineJoin: CGLineJoin.round, miterLimit: 0.1, dash: [], dashPhase: 0)
    let markerColor = Color(.blue)
}


struct Canvas_Previews: PreviewProvider {
    static var previews: some View {
        SwipeDraw(model: SwipeDrawModel(), dimension:CGSize(width: 640, height: 480))
    }
}


