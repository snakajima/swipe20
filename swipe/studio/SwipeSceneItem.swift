//
//  SwipeSceneItem.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 12/12/20.
//

import SwiftUI

struct SwipeSceneItem: View {
    @ObservedObject var model:SwipeCanvasModel
    @State var index:Int
    @State private var snapshot: SwipeView.Snapshot? = nil
    let previewHeight:CGFloat
    let selectionColor:Color
    let buttonColor:Color
    let pub = NotificationCenter.default.publisher(for: SwipeCanvasModel.s_sceneSaved)
    var body: some View {
        VStack(spacing:1) {
            let scale = previewHeight / model.scene.dimension.height
            let width = model.scene.dimension.width * scale
            ZStack {
                SwipeView(scene: model.scene, frameIndex: $index, scale:scale, snapshot: index == model.frameIndex ? snapshot : nil)
                if index == model.frameIndex {
                    Rectangle()
                        .stroke(lineWidth: 3.0)
                        .foregroundColor(selectionColor)
                        .padding(2.0)
                }
            }
            .frame(width:width, height:previewHeight)
            .gesture(TapGesture().onEnded() {
                print("### item tapped", model.frameIndex, index)
                model.frameIndex = index
                snapshot = SwipeView.Snapshot(frameIndex: model.frameIndex, ratio: 0.0, callback: { (osView, layer) in
                    UIGraphicsBeginImageContext(osView.bounds.size)
                    osView.drawHierarchy(in: osView.bounds, afterScreenUpdates: false)
                    if let image = UIGraphicsGetImageFromCurrentImageContext(),
                       let sceneObject = SceneObject.sceneObject(with: model.scene.uuid) {
                        sceneObject.thumbnail = image.pngData()
                        PersistenceController.shared.saveContext()
                    }
                    UIGraphicsEndImageContext()
                    DispatchQueue.main.async {
                        self.snapshot = nil
                    }
                })
            })
            .onReceive(pub) { output in
                print("notified")
            }
            HStack(spacing:4) {
                if model.scene.frameCount > 1 {
                    Button(action: {
                        model.scene = model.scene.frameDeleted(atIndex: index)
                    }) {
                        SwipeSymbol.trash.frame(width:32, height:44)
                            .foregroundColor(buttonColor)
                    }.frame(width:44, height:44)
                }
                Spacer()
                /*
                Button(action: {
                    print("star")
                }) {
                    SwipeSymbol.gearshape.frame(width:32, height:44)
                        .foregroundColor(buttonColor)
                }.frame(width:44, height:44)
                */
                Button(action:{
                    model.scene = model.scene.frameDuplicated(atIndex: index)
                    model.frameIndex = index + 1
                }) {
                    SwipeSymbol.duplicate.frame(width:32, height:44)
                        .foregroundColor(buttonColor)
                }.frame(width:44, height:44)
            }.frame(width:width, height:44, alignment: .center)
        }
    }
}
