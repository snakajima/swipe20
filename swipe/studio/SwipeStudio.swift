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
        SwipeScene(s_scriptSample),
        SwipeScene(s_scriptSample),
        SwipeScene(s_scriptSample),
    ]

    public var body: some View {
        let previewHeight:CGFloat = s_previewHeight
        return NavigationView {
            List(scenes.indices) { index in
                let model = SwipeCanvasModel(scene:scenes[index])
                NavigationLink(destination:
                    SwipeCanvas(model: model, previewHeight: previewHeight)
                ) {
                    Text("Sample")
                }
/*
 NavigationLink(destination:
                    SwipeCanvas(model: model, previewHeight: previewHeight)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .bottomBar) {
                                Button("Presse Me") {
                                    let script = model.scene.script
                                    let data = try? JSONSerialization.data(withJSONObject: script, options: JSONSerialization.WritingOptions.prettyPrinted)
                                    let str = String(bytes: data!, encoding: .utf8)
                                    print("pressed", str ?? "#ERR")
                                    self.scenes[index] = SwipeScene(script)
                                }
                            }
                        }
                ) {
                    Text("Sample")
                }
*/
            }
        }
    }
}

struct SwipeStudio_Previews: PreviewProvider {
    static var previews: some View {
        SwipeStudio()
    }
}
