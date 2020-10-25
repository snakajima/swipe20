//
//  SwipeSceneList.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 10/6/20.
//

import SwiftUI

struct SwipeSceneList: View {
    @ObservedObject var model:SwipeCanvasModel
    var body: some View {
        ScrollView (.horizontal, showsIndicators: true) {
            HStack(spacing:1) {
                ForEach(0..<model.scene.frameCount, id:\.self) { index in
                    SwipeSceneItem(model:model, index: index)
                }
            }.frame(height:120)
        }
    }
}

struct SwipeSceneItem: View {
    @ObservedObject var model:SwipeCanvasModel
    let index:Int
    var body: some View {
        HStack(spacing:1) {
            VStack(spacing:1) {
                GeometryReader { geometry in
                    let scale = geometry.size.height / model.scene.dimension.height
                    let _ = print("*** scale", scale)
                    ZStack {
                        SwipePreview(scene: model.scene, scale:scale, frameIndex: index)
                        if index == model.frameIndex {
                            Rectangle()
                                .stroke(lineWidth: 1.0)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(width: model.scene.dimension.width * scale)
                    .gesture(TapGesture().onEnded() {
                        model.frameIndex = index
                    })
                }
                HStack(spacing:4) {
                    Button(action: {
                        model.scene = model.scene.frameDeleted(atIndex: index)
                    }) {
                        SwipeSymbol.trash.frame(width:20, height:20)
                    }.disabled(model.scene.frameCount == 1)
                    Spacer()
                    Button(action: {
                        print("star")
                    }) {
                        SwipeSymbol.gearshape.frame(width:20, height:20)
                    }
                }
            }
            Button(action:{
                model.scene = model.scene.frameDuplicated(atIndex: index)
                model.frameIndex = index + 1
            }) {
                SwipeSymbol.plus.frame(width:20, height:20)
            }
        }
    }
}
