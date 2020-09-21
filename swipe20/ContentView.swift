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
            //Playground()
            SwipeView(scene:scene, pageIndex:$page)
            Text("PageIndex = \(self.page)")
            Button("Play") {
                print("play")
                self.page += 1
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
