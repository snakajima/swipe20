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
    let options:[String:Any]?
}
let s_samples = [
    Sample(title: "Hello World", filename: "HelloWorld", options:nil),
    Sample(title: "Rotation", filename: "Rotation", options:nil),
    Sample(title: "AnchorPoint", filename: "AnchorPoint", options:nil),
    Sample(title: "Opacity", filename: "Opacity", options:nil),
    Sample(title: "Nested", filename: "Nested", options:nil),
    Sample(title: "Duration", filename: "Duration", options:nil),
    Sample(title: "Shapes", filename: "Shapes", options:nil),
    Sample(title: "Sample 2", filename: "sample1", options:nil),
    Sample(title: "Hello World", filename: "HelloWorld", options:["alt":true]),
    Sample(title: "Rotation", filename: "Rotation", options:["alt":true]),
    Sample(title: "AnchorPoint", filename: "AnchorPoint", options:["alt":true]),
    Sample(title: "Opacity", filename: "Opacity", options:["alt":true]),
    Sample(title: "Nested", filename: "Nested", options:["alt":true]),
    Sample(title: "Duration", filename: "Duration", options:["alt":true]),
]

struct ContentView: View {
    var body: some View {
        NavigationView {
            List(s_samples) { sample in
                NavigationLink(destination: SwipeFileView(sample.filename, options: sample.options)) {
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
