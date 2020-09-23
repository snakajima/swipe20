//
//  Playground2.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/23/20.
//

import SwiftUI

struct LayerTestView: NSViewRepresentable {
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeNSView(context: Context) -> some NSView {
        let nsView = NSView()
        let layer = CALayer()
        layer.backgroundColor = NSColor.yellow.cgColor
        let layer1 = CALayer()
        layer1.backgroundColor = NSColor.blue.cgColor
        layer1.frame = CGRect(x:200, y:10, width:100, height:100)
        layer.addSublayer(layer1)
        nsView.layer = layer
        return nsView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
    }

    class Coordinator: NSObject {
        let view: LayerTestView
        
        init(_ view: LayerTestView) {
            self.view = view
        }
    }
}

struct Playground2_Previews: PreviewProvider {
    static var previews: some View {
        Playground2_view()
    }
}

struct Playground2_view: View {
    @State private var value: Double = 0
    var body: some View {
        VStack {
            LayerTestView()
            Slider(value: $value, in: 0...1.0)
        }
    }
}
