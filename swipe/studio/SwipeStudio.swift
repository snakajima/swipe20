//
//  SwipeStudio.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 10/26/20.
//

import SwiftUI

public struct SwipeStudio: View {
    
    public var body: some View {
        NavigationView {
            let model = SwipeCanvasModel(scene:SwipeScene(s_scriptSample))
            NavigationLink(
                destination:
                    SwipeCanvas(model: model)
                    .navigationTitle("Swipe Studio")
                    .toolbar {
                        ToolbarItem {
                            Button("Presse Me") {
                                print("pressed")
                            }
                        }
                    },
                label: {
                    Text("Sample")
                })
        }
    }
}

struct SwipeStudio_Previews: PreviewProvider {
    static var previews: some View {
        SwipeStudio()
    }
}
