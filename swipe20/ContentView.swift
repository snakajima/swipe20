//
//  ContentView.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//

import SwiftUI


struct ContentView: View {
    @State var frameIndex = 0
    let scene:SwipeScene
    
    init() {
        if let path = Bundle.main.path(forResource: "sample1", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let json = try?  JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String:Any] {
            self.scene = SwipeScene(json)
            print("success")
        } else {
            self.scene = SwipeScene(s_script1)
            print("fail")
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
    }
}
