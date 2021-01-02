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
    let pub = NotificationCenter.default.publisher(for: SwipeCanvasModel.s_sceneSaved)
    var isSelected:Bool {index == model.frameIndex }
    
    func takeSnapshot(saveState:Bool) {
        snapshot = SwipeView.Snapshot(frameIndex: model.frameIndex, ratio: 0.0, callback: { (osView, size, layer) in
            UIGraphicsBeginImageContext(osView.bounds.size)
            osView.drawHierarchy(in: osView.bounds, afterScreenUpdates: false)
            if let image = UIGraphicsGetImageFromCurrentImageContext(),
               let sceneObject = SceneObject.sceneObject(with: model.scene.uuid) {
                sceneObject.thumbnail = image.pngData()
                if saveState,
                   let data = try? JSONSerialization.data(withJSONObject: model.state, options: []) {
                    sceneObject.state = data
                }
                PersistenceController.shared.saveContext()
            }
            UIGraphicsEndImageContext()
            DispatchQueue.main.async {
                self.snapshot = nil
            }
        })
    }
    
    var body: some View {
        let scale = previewHeight / model.scene.dimension.height
        let width = model.scene.dimension.width * scale
        HStack(spacing:0) {
            VStack(spacing:0) {
                ZStack {
                    SwipeView(scene: model.scene, frameIndex: $index, scale:scale, snapshot: index == model.frameIndex ? snapshot : nil)
                    if  isSelected {
                        Rectangle()
                            .stroke(lineWidth: 3.0)
                            .foregroundColor(selectionColor)
                            .padding(2.0)
                    }
                }
                .frame(width:width, height:previewHeight)
                .gesture(TapGesture().onEnded() {
                    model.frameIndex = index
                    takeSnapshot(saveState: true)
                })
                .onReceive(pub) { notification in
                    if isSelected, let scene = notification.object as? SwipeScene, scene.uuid == model.scene.uuid {
                        takeSnapshot(saveState: false)
                    }
                }
                Rectangle().frame(height:2).foregroundColor(.clear)
            }
            VStack(spacing:0) {
                if model.scene.frameCount > 1 {
                    Button(action: {
                        // We don't need to worry about mode.frameIndex becoming out of range,
                        // because the model will handle it in didSet of scene
                        model.scene = model.scene.deleteFrame(atIndex: index)
                        takeSnapshot(saveState: true)
                    }) {
                        SwipeSymbol.trash.frame(width:32, height:32)
                            .foregroundColor(.accentColor)
                    }.frame(width:44, height:32)
                }
                Button(action:{
                    model.scene = model.scene.duplicateFrame(atIndex: index)
                    model.frameIndex = index + 1
                    takeSnapshot(saveState: true)
                }) {
                    HStack {
                        SwipeSymbol.duplicate.frame(width:32, height:32)
                            .foregroundColor(.accentColor)
                        if model.scene.frameCount == 1 {
                            Text("duplicate")
                        }
                    }
                }
            }
        }
    }
}
