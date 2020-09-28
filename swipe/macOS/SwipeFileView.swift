//
//  SwipeFileView.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/22/20.
//
import SwiftUI

#if os(macOS)
public struct SwipeFileView: View {
    @State var frameIndex = 0
    let scene:SwipeScene
    
    init(_ filename:String, options:[String:Any]? = nil) {
        if let path = Bundle.main.path(forResource: filename, ofType: "swipe"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let json = try?  JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String:Any] {
            self.scene = SwipeScene(json)
        } else {
            self.scene = SwipeScene([:])
            print("load JSON failed")
        }
    }

    public var body: some View {
        VStack {
            SwipeView(scene:scene, frameIndex:$frameIndex)
            HStack {
                Button("Prev") {
                    self.frameIndex -= 1
                }
                .disabled(frameIndex <= 0)
                Button("Next") {
                    self.frameIndex += 1
                }
                .disabled(frameIndex >= scene.frameCount - 1)
                Text(scene.name(ofFrameAtIndex: frameIndex))
            }
        }
    }
}

struct SwipeFileView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeFileView("Nested")
    }
}
#endif
