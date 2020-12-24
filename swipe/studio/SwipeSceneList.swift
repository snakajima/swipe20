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
    @Binding var snapshot: SwipeView.Snapshot?
    var body: some View {
        ScrollView (.horizontal, showsIndicators: true) {
            HStack(spacing:1) {
                ForEach(0..<model.scene.frameCount, id:\.self) { index in
                    SwipeSceneItem(model:model, index: index,
                                   previewHeight: previewHeight,
                                   selectionColor: selectionColor)
                }
                if model.scene.frameCount > 1 {
                    SwipeExporter(scene:model.scene, snapshot:$snapshot)
                }
            }
        }
    }
}

struct SwipeSceneList_Previews: PreviewProvider {
    @State static var snapshot: SwipeView.Snapshot? = nil
    static var previews: some View {
        SwipeSceneList( model:SwipeCanvasModel(scene:SwipeScene(s_scriptSample)), previewHeight: 180,
                        selectionColor: .blue, snapshot: $snapshot)
        .background(Color(.sRGB, red: 1.0, green: 1.0, blue: 0.8, opacity: 1.0))
    }
}
