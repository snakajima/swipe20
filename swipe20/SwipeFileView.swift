//
//  SwipeFileView.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/22/20.
//
import SwiftUI

struct SwipeFileView: View {
    @State var frameIndex = 0
    let scene:SwipeScene
    
    init(_ filename:String) {
        if let path = Bundle.main.path(forResource: filename, ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let json = try?  JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String:Any] {
            self.scene = SwipeScene(json)
        } else {
            self.scene = SwipeScene([:])
            print("load JSON failed")
        }
    }

    var body: some View {
        VStack {
            SwipeView(scene:scene, frameIndex:frameIndex)
            HStack {
                Button("Prev") {
                    self.frameIndex -= 1
                }
                .disabled(frameIndex <= 0)
                Button("Next") {
                    self.frameIndex += 1
                }
                .disabled(frameIndex >= scene.frameCount - 1)
                Text("Frame#: \(self.frameIndex)")
            }
        }
    }
}

struct SwipeFileView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeFileView("sample1")
    }
}
