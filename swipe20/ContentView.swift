//
//  ContentView.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//

import SwiftUI

let scene = SwipeScene(s_script1)

struct ContentView: View {
    @State var frameIndex = 0
    var body: some View {
        VStack {
            //Playground()
            SwipeView(scene:scene, frameIndex:frameIndex)
            Text("PageIndex = \(self.frameIndex)")
            Button("Prev") {
                self.frameIndex -= 1
            }
            .disabled(frameIndex <= 0)
            Button("Next") {
                self.frameIndex += 1
            }
            .disabled(frameIndex >= scene.frameCount - 1)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
