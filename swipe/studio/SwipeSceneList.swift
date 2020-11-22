//
//  SwipeSceneList.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 10/6/20.
//

import SwiftUI
import ImageIO
import MobileCoreServices

struct SwipeSceneList: View {
    @ObservedObject var model:SwipeCanvasModel
    let previewHeight:CGFloat
    let selectionColor:Color
    let buttonColor:Color
    var body: some View {
        ScrollView (.horizontal, showsIndicators: true) {
            HStack(spacing:1) {
                ForEach(0..<model.scene.frameCount, id:\.self) { index in
                    SwipeSceneItem(model:model, index: index,
                                   previewHeight: previewHeight,
                                   selectionColor: selectionColor,
                                   buttonColor: buttonColor)
                }
                if model.scene.frameCount > 1 {
                    SwipeExporter(scene:model.scene)
                }
            }
        }
    }
}

struct SwipeExporter: View {
    let scene:SwipeScene
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                export()
            }, label: {
                Text("Export")
            })
            Spacer()
            Rectangle()
                .frame(height:32)
        }
    }
    func export() {
        print("export")
        guard let folderURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            print("### ERRROR no document folder ###")
            return
        }
        let fileURL = folderURL.appendingPathComponent("swipeanime.gif")
        let fileProps = [kCGImagePropertyGIFLoopCount:0]
        //let frameProps = [kCGImagePropertyGIFDelayTime:0.1]
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypeGIF, 10, fileProps as CFDictionary) else {
            print("### ERROR can't create destination")
            return
        }
        //CGImageDestinationAddImage(destination, image, frameProps as CFDictionary)
        CGImageDestinationFinalize(destination)
        print("fileURL", fileURL)
    }
}

struct SwipeSceneItem: View {
    @ObservedObject var model:SwipeCanvasModel
    @State var index:Int
    let previewHeight:CGFloat
    let selectionColor:Color
    let buttonColor:Color
    var body: some View {
        VStack(spacing:1) {
            let scale = previewHeight / model.scene.dimension.height
            ZStack {
                SwipeView(scene: model.scene, frameIndex: $index, scale:scale)
                if index == model.frameIndex {
                    Rectangle()
                        .stroke(lineWidth: 3.0)
                        .foregroundColor(selectionColor)
                        .padding(2.0)
                }
            }
            .frame(width:model.scene.dimension.width * scale, height:previewHeight)
            .gesture(TapGesture().onEnded() {
                model.frameIndex = index
            })
            HStack(spacing:4) {
                if model.scene.frameCount > 1 {
                    Button(action: {
                        model.scene = model.scene.frameDeleted(atIndex: index)
                    }) {
                        SwipeSymbol.trash.frame(width:24, height:24)
                            .foregroundColor(buttonColor)
                    }.frame(height:32)
                }
                Spacer()
                Button(action: {
                    print("star")
                }) {
                    SwipeSymbol.gearshape.frame(width:24, height:24)
                        .foregroundColor(buttonColor)
                }.frame(height:32)
                Button(action:{
                    model.scene = model.scene.frameDuplicated(atIndex: index)
                    model.frameIndex = index + 1
                }) {
                    SwipeSymbol.duplicate.frame(width:24, height:24)
                        .foregroundColor(buttonColor)
                }.frame(height:32)
            }.frame(height:32, alignment: .bottomLeading)
        }
    }
}

struct SwipeSceneList_Previews: PreviewProvider {
    static var previews: some View {
        SwipeSceneList( model:SwipeCanvasModel(scene:SwipeScene(s_scriptSample)), previewHeight: 180,
                        selectionColor: .blue, buttonColor: .blue)
        .background(Color(.sRGB, red: 1.0, green: 1.0, blue: 0.8, opacity: 1.0))
    }
}
