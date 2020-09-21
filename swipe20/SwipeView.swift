//
//  SwipeView.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//

import Foundation
import SwiftUI

struct SwipeView: NSViewRepresentable {
    init(_ script:[String:Any]) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeNSView(context: Context) -> some NSView {
        let nsView = NSView()
        nsView.layer = CALayer()
        return nsView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        if let layer = nsView.layer {
            layer.backgroundColor = NSColor.yellow.cgColor
        }
        //
    }

    class Coordinator: NSObject {
        let view: SwipeView
        init(_ view: SwipeView) {
            self.view = view
        }
    }
}

private let s_script1 = [
    "elements":[
        "text":"Hello World"
    ]
]
struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeView(s_script1)
    }
}
