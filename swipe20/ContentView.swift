//
//  ContentView.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//

import SwiftUI

let scene = SwipeScene(s_script1)

struct ContentView: View {
    @State var page = 0
    var body: some View {
        VStack {
            SwipeView(scene:scene)
            Button("Play") {
                print("play")
                self.page = 1
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
