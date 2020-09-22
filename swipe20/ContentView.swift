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
    Sample(title: "Sample 1", filename: "sample1"),
    Sample(title: "Sample 2", filename: "sample1"),
]

struct ContentView: View {
    var body: some View {
        NavigationView {
            List(s_samples) { sample in
                NavigationLink(destination: SwipeFileView(sample.filename)) {
                    Text(sample.title)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
