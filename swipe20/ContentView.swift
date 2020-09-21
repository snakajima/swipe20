//
//  ContentView.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            let scene = SwipeScene(s_script1)
            SwipeView(scene:scene)
            Button("Play") {
                print("play")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
