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
    let selectionColor:Color
    let buttonColor:Color
    @Binding var snapshot: SwipeView.Snapshot?
    var body: some View {
        ScrollView (.horizontal, showsIndicators: true) {
            HStack(spacing:1) {
                ForEach(0..<model.scene.frameCount, id:\.self) { index in
                    SwipeSceneItem(model:model, index: index, snapshot: $snapshot,
                                   previewHeight: previewHeight,
                                   selectionColor: selectionColor,
                                   buttonColor: buttonColor)
                }
                if model.scene.frameCount > 1 {
                    SwipeExporter(scene:model.scene, snapshot:$snapshot)
                }
            }
        }
    }
}

struct SwipeSceneItem: View {
    @ObservedObject var model:SwipeCanvasModel
    @State var index:Int
    @Binding var snapshot: SwipeView.Snapshot?
    let previewHeight:CGFloat
    let selectionColor:Color
    let buttonColor:Color
    var body: some View {
        VStack(spacing:1) {
            let scale = previewHeight / model.scene.dimension.height
            let width = model.scene.dimension.width * scale
            ZStack {
                SwipeView(scene: model.scene, frameIndex: $index, scale:scale)
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
                model.frameIndex = index
            })
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

struct SwipeSceneList_Previews: PreviewProvider {
    @State static var snapshot: SwipeView.Snapshot? = nil
    static var previews: some View {
        SwipeSceneList( model:SwipeCanvasModel(scene:SwipeScene(s_scriptSample)), previewHeight: 180,
                        selectionColor: .blue, buttonColor: .blue, snapshot: $snapshot)
        .background(Color(.sRGB, red: 1.0, green: 1.0, blue: 0.8, opacity: 1.0))
    }
}
