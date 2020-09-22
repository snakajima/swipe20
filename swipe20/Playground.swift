//
//  Playground.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/21/20.
//
import SwiftUI

struct Playground: View {
    @State var value = CGFloat(0)
    @State var color = Color.green
    @State var opacity = 1.0
    var body: some View {
        VStack {
            Rectangle()
                .fill(color)
                .opacity(opacity)
                .frame(width:100, height:100)
            Text("Hello World \(value)")
            Button("Test") {
                withAnimation(.easeIn(duration: 2.0)) { () -> Void in
                    self.value += 1
                    switch(self.value) {
                    case 1:
                        self.color = Color.blue
                    case 2:
                        self.color = Color.red
                    case 3:
                        self.color = Color.yellow
                    case 4:
                        self.color = Color.black
                    default:
                        self.color = Color.blue
                        self.opacity = 0
                    }
                }
            }
        }
    }
}

struct Playground_Previews: PreviewProvider {
    static var previews: some View {
        Playground()
    }
}
