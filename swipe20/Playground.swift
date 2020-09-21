//
//  Playground.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/21/20.
//
import SwiftUI

struct Playground: View {
    @State var value = 1
    var body: some View {
        VStack {
            Text("Hello World \(value)")
            Button("Test") {
                self.value += 1
            }
        }
    }
}

struct Playground_Previews: PreviewProvider {
    static var previews: some View {
        Playground()
    }
}
