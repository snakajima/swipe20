//
//  SwipeSymbol.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 10/4/20.
//

import SwiftUI
import CoreGraphics
#if os(macOS)
    import AppKit
    public typealias OSFont = NSFont
#elseif os(iOS) || os(tvOS)
    import UIKit
    public typealias OSFont = UIFont
#endif

let s_trash:[String:Any] = [
    "path":"M 46.4844 32.4707 L 104.98 32.4707 C 116.895 32.4707 123.926 26.3672 124.463 14.3555 L 128.369 -73.1445 L 133.105 -73.1445 C 138.086 -73.1445 141.748 -76.6113 141.748 -81.5918 C 141.748 -86.4746 138.086 -89.8926 133.105 -89.8926 L 107.666 -89.8926 L 107.666 -98.584 C 107.666 -110.059 100.635 -116.309 87.6465 -116.309 L 63.7207 -116.309 C 50.7324 -116.309 43.7012 -110.059 43.7012 -98.584 L 43.7012 -89.8926 L 18.3105 -89.8926 C 13.3301 -89.8926 9.66797 -86.4746 9.66797 -81.5918 C 9.66797 -76.6113 13.3301 -73.1445 18.3105 -73.1445 L 23.0469 -73.1445 L 26.9531 14.3555 C 27.4902 26.416 34.4727 32.4707 46.4844 32.4707 Z M 61.1816 -98.1445 C 61.1816 -100.195 62.6465 -101.465 65.0879 -101.465 L 86.2793 -101.465 C 88.7207 -101.465 90.1855 -100.195 90.1855 -98.1445 L 90.1855 -89.8926 L 61.1816 -89.8926 Z M 49.0234 15.3809 C 45.9473 15.3809 44.2383 13.3789 44.0918 9.66797 L 40.2832 -73.1445 L 111.035 -73.1445 L 107.324 9.66797 C 107.178 13.3789 105.518 15.3809 102.393 15.3809 Z M 57.4707 7.4707 C 61.1328 7.4707 63.4277 5.12695 63.2812 1.66016 L 61.4746 -59.375 C 61.377 -62.7441 59.0332 -65.0391 55.4688 -65.0391 C 51.9531 -65.0391 49.707 -62.7441 49.8535 -59.2773 L 51.6602 1.80664 C 51.8066 5.17578 54.1504 7.4707 57.4707 7.4707 Z M 75.7324 7.4707 C 79.1504 7.4707 81.4941 5.22461 81.4941 1.85547 L 81.4941 -59.4238 C 81.4941 -62.793 79.1504 -65.0391 75.7324 -65.0391 C 72.2656 -65.0391 69.9219 -62.793 69.9219 -59.4238 L 69.9219 1.85547 C 69.9219 5.22461 72.2656 7.4707 75.7324 7.4707 Z M 93.9453 7.4707 C 97.2656 7.4707 99.6094 5.17578 99.7559 1.80664 L 101.562 -59.2773 C 101.709 -62.7441 99.4629 -65.0391 95.9473 -65.0391 C 92.4316 -65.0391 90.0391 -62.7441 89.9414 -59.375 L 88.1348 1.66016 C 87.9883 5.12695 90.2832 7.4707 93.9453 7.4707 Z"
]

struct SwipeSymbol: View {
    //let script:[String:Any]
    let path:CGPath
    let bound:CGRect
    static let emtyPath = CGPath(rect: .zero, transform: nil)
    init(script:[String:Any]) {
        path = SwipePath.parse(script["path"]) ?? Self.emtyPath
        bound = path.boundingBoxOfPath
    }
    func path(geometry:GeometryProxy) -> CGPath {
        let ratio = min(geometry.size.height / bound.height, geometry.size.width / bound.width)
        var xf = CGAffineTransform(scaleX: ratio, y: ratio)
        return path.copy(using: &xf) ?? Self.emtyPath
    }
    public var body: some View {
        GeometryReader { geometry in
            Path(path(geometry: geometry))
        }.alignmentGuide(.firstTextBaseline, computeValue: { d in
            return 0
        })
    }
}

struct SwipeSymbol_Previews: PreviewProvider {
    static let bigFont = OSFont.systemFont(ofSize: 70)
    static let smallFont = OSFont.systemFont(ofSize: 24)
    static var previews: some View {
        VStack {
            Text("Hello")
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("Hello")
                SwipeSymbol(script:s_trash).frame(width:70, height:70)
                Text("Hello").font(Font(bigFont))
                Text("Hello")
            }
            Text("Hello")
        }
    }
}
