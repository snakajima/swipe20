//
//  SwipeStudio.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 10/26/20.
//

import SwiftUI

#if os(macOS)
let s_previewHeight:CGFloat = 150
#else
let s_previewHeight:CGFloat = 100
#endif


public struct SwipeStudio: View {
    @State private var scenes = [
        SwipeScene(s_scriptEmpty),
        SwipeScene(s_scriptGen),
        SwipeScene(s_scriptSample),
    ]
    let selectionColor = Color(Color.RGBColorSpace.sRGB, red: 0.0, green: 1.0, blue: 1.0, opacity: 0.8)
    let buttonColor = Color.blue

    public var body: some View {
        let previewHeight:CGFloat = s_previewHeight
        #if os(macOS)
        return NavigationView {
            List(scenes.indices) { index in
                let model = SwipeCanvasModel(scene:scenes[index])
                let drawModel = SwipeDrawModel()
                NavigationLink(destination:
                                SwipeCanvas(model: model, drawModel:drawModel, previewHeight: previewHeight, selectionColor: selectionColor, buttonColor: buttonColor)
                ) {
                    Text("Sample")
                }
            }
        }
        #else
        return NavigationView {
            List(scenes.indices) { index in
                let model = SwipeCanvasModel(scene:scenes[index])
                let drawModel = SwipeDrawModel()
                NavigationLink(destination:
                                SwipeCanvas(model: model, drawModel:drawModel, previewHeight: previewHeight, selectionColor: selectionColor, buttonColor: buttonColor)
                ) {
                    Text("Sample")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        #endif
    }
}

struct SwipeStudio_Previews: PreviewProvider {
    static var previews: some View {
        SwipeStudio()
    }
}
