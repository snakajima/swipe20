//
//  Playground.swift
//  SwipeStudio Lite
//
//  Created by SATOSHI NAKAJIMA on 10/30/20.
//

import SwiftUI

struct NumberHolder: Identifiable {
    let id = UUID()
    let value:Int
}

struct Playground: View {
    @State var numbers:[NumberHolder] = [
        NumberHolder(value:1),
        NumberHolder(value:2),
        NumberHolder(value:3),
        NumberHolder(value:4),
    ]
    var body: some View {
        NavigationView {
            List(numbers.indices) { index in
                let number = numbers[index]
                NavigationLink(destination: VStack {
                    Text("Hello \(number.value)")
                    Button("Increment") {
                        numbers[index] = NumberHolder(value: number.value + 1)
                    }
                } ) {
                    Text("Hello \(number.value)")
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


