//
//  ContentView.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import SwiftUI

struct Sample: Identifiable {
    let id = UUID()
    let title:String
    let filename:String
}
let s_samples = [
    Sample(title: "Hello World", filename: "HelloWorld"),
    Sample(title: "Rotation", filename: "Rotation"),
    Sample(title: "AnchorPoint", filename: "AnchorPoint"),
    Sample(title: "Opacity", filename: "Opacity"),
    Sample(title: "Nested", filename: "Nested"),
    Sample(title: "Duration", filename: "Duration"),
    Sample(title: "Shapes", filename: "Shapes"),
    Sample(title: "Sample 2", filename: "sample1"),
    Sample(title: "Slides", filename: "Slides"),
    Sample(title: "Bounce", filename: "Bounce"),
    Sample(title: "Jump", filename: "Jump"),
    Sample(title: "Leap", filename: "Leap"),
    Sample(title: "Sample1", filename: "sample1"),
]

struct ContentView: View {
    var body: some View {
        NavigationView {
            List(s_samples) { sample in
                NavigationLink(destination: SwipeFileView(sample.filename)) {
                    Text(sample.title)
                }
            }.frame(maxWidth:200)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
