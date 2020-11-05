//
//  SwipeSceneList.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 10/6/20.
//

import SwiftUI

struct SwipeSceneList: View {
    @ObservedObject var model:SwipeCanvasModel
    let previewHeight:CGFloat
    var body: some View {
        ScrollView (.horizontal, showsIndicators: true) {
            HStack(spacing:1) {
                ForEach(0..<model.scene.frameCount, id:\.self) { index in
                    SwipeSceneItem(model:model, index: index, previewHeight: previewHeight)
                }
            }
        }
    }
}

struct SwipeSceneItem: View {
    @ObservedObject var model:SwipeCanvasModel
    @State var index:Int
    let previewHeight:CGFloat
    var body: some View {
        HStack(spacing:1) {
            VStack(spacing:1) {
                let scale = previewHeight / model.scene.dimension.height
                ZStack {
                    SwipeView(scene: model.scene, frameIndex: $index, scale:scale)
                    if index == model.frameIndex {
                        Rectangle()
                            .stroke(lineWidth: 1.0)
                            .foregroundColor(.blue)
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
                            SwipeSymbol.trash.frame(width:20, height:20)
                                .foregroundColor(.blue)
                        }
                    }
                    Spacer()
                    Button(action: {
                        print("star")
                    }) {
                        SwipeSymbol.gearshape.frame(width:20, height:20)
                            .foregroundColor(.blue)
                    }
                }
            }
            Button(action:{
                model.scene = model.scene.frameDuplicated(atIndex: index)
                model.frameIndex = index + 1
            }) {
                SwipeSymbol.plus.frame(width:20, height:20)
                    .foregroundColor(.blue)
            }
        }
    }
}
