//
//  SwipeExporter.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/22/20.
//

import SwiftUI
import ImageIO
import MobileCoreServices

struct SwipeExporter: View {
    let scene:SwipeScene
    var body: some View {
        VStack {
            Button(action: {
                export()
            }, label: {
                Text("Explort")
            })
            Rectangle()
                .fill(Color.clear)
                .frame(height:16)
        }
    }
    func export() {
        print("export")
        guard let folderURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            print("### ERRROR no document folder ###")
            return
        }
        let fileURL = folderURL.appendingPathComponent("swipeanime.gif")
        let fileProps = [kCGImagePropertyGIFLoopCount:0]
        let frameProps = [kCGImagePropertyGIFDelayTime:1.0/30.0]
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypeGIF, 10, fileProps as CFDictionary) else {
            print("### ERROR can't create destination")
            return
        }
        let renderer = SwipeCALayer(scene: scene)
        let layer = renderer.makeLayer()
        guard let sublayers = layer.sublayers else {
            print("### ERROR no sublayers")
            return
        }
        UIGraphicsBeginImageContext(scene.dimension)
        let ctx = UIGraphicsGetCurrentContext()!
        layer.render(in: ctx)
        let image = UIGraphicsGetImageFromCurrentImageContext()!.cgImage!
        CGImageDestinationAddImage(destination, image, frameProps as CFDictionary)
        let frame = scene.frames[0]
        let frameNext = scene.frames[1]
        for index in 1..<30 {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            frameNext.apply(to: sublayers, ratio: Double(index) / 30.0, transition: .next, base: frame)
            CATransaction.commit()
            layer.render(in: ctx)
            let image = UIGraphicsGetImageFromCurrentImageContext()!.cgImage!
            CGImageDestinationAddImage(destination, image, frameProps as CFDictionary)
        }
        UIGraphicsEndImageContext()
        
        CGImageDestinationFinalize(destination)
        print("fileURL", fileURL)
    }
}

struct SwipeExporter_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            SwipeExporter(scene: SwipeScene(s_scriptSample))
                .background(Color(.sRGB, red: 1.0, green: 1.0, blue: 0.8, opacity: 1.0))
            Spacer()
        }.background(Color(.sRGB, red: 1.0, green: 0.0, blue: 0.8, opacity: 1.0))
    }
}
