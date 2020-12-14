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
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image? = nil
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let scale:CGFloat = min(geometry.size.height / dimension.height, geometry.size.width / dimension.width)
                let drag = DragGesture(minimumDistance: 0.1)
                    .onChanged { model.onChanged($0.location) }
                    .onEnded { model.onEnded($0.location, scale:scale) }
                let style = markerStyle(scale: scale)
                #if os(macOS)
                let markerColor = Color(OSColor(cgColor: model.strokeColor) ?? OSColor.white)
                #else
                let markerColor = Color(model.strokeColor)
                #endif
                ZStack {
                    if let inputImage = inputImage {
                        Image(uiImage: inputImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width, height:geometry.size.height)
                            .opacity(0.5)
                    }
                    ForEach(model.strokes) { stroke in
                        Path {
                            stroke.append(to: &$0)
                        }
                        .stroke(style:style)
                        .fill(markerColor)
                    }
                    Path {
                        model.currentStroke.append(to: &$0)
                    }
                    .stroke(style:style)
                    .fill(markerColor)
                    .background(Color(white: 1.0, opacity: 0.1))
                    .gesture(drag)
                }
            }
            HStack {
                Button(action: {
                    model.undo()
                }) {
                    SwipeSymbol.backward.frame(width:32, height:32)
                        .foregroundColor(model.undoable ? .accentColor: .gray)
                }
                .disabled(!model.undoable)
                Button(action: {
                    model.redo()
                }) {
                    SwipeSymbol.forward.frame(width:32, height:32)
                        .foregroundColor(model.redoable ? .accentColor: .gray)
                }
                .disabled(!model.redoable)
                Spacer()
                Button(action: {
                    print("photo")
                    self.showingImagePicker = true
                }, label: {
                    SwipeSymbol.photo.frame(width:32, height:32)
                        .foregroundColor(.accentColor)
                })
                Spacer()
                Button(action: {
                    model.done(style:.leap)
                }, label: {
                    SwipeSymbol.hare.frame(width:32, height:32)
                        .foregroundColor(.accentColor)
                })
                Button(action: {
                    model.done(style:.jump)
                }, label: {
                    SwipeSymbol.frog.frame(width:32, height:32)
                        .foregroundColor(.accentColor)
                })
                Button(action: {
                    model.done(style:.summersault)
                }, label: {
                    SwipeSymbol.frog.frame(width:32, height:32)
                        .rotationEffect(.radians(.pi))
                        .foregroundColor(.accentColor)
                })
            }
            .frame(height:32, alignment: .bottom)
            .background(Color(.sRGB, red: 1.0, green: 1.0, blue: 0.8, opacity: 1.0))
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage, content: {
            ImagePicker(image: $inputImage)
        })
    }
    
    func loadImage() {
        //guard let inputImage = inputImage else { return }
        print("loadImage")
        //image = Image(uiImage: inputImage)
    }
    
    func markerStyle(scale:CGFloat) -> StrokeStyle {
        return StrokeStyle(lineWidth: model.lineWidth * scale, lineCap: CGLineCap.round, lineJoin: CGLineJoin.round, miterLimit: 0.1, dash: [], dashPhase: 0)
    }
    //let markerColor = Color(.white)
}


struct Canvas_Previews: PreviewProvider {
    static var previews: some View {
        SwipeDraw(model: SwipeDrawModel(), dimension:CGSize(width: 640, height: 480))
    }
}


