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
            Spacer()
            Button(action: {
                export()
            }, label: {
                Text("Export")
            })
            Spacer()
            Rectangle()
                .frame(height:32)
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
        let frameProps = [kCGImagePropertyGIFDelayTime:0.1]
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypeGIF, 1, fileProps as CFDictionary) else {
            print("### ERROR can't create destination")
            return
        }
        let renderer = SwipeCALayer(scene: scene)
        let layer = renderer.makeLayer()
        UIGraphicsBeginImageContext(scene.dimension)
        let ctx = UIGraphicsGetCurrentContext()!
        layer.render(in: ctx)
        let image = UIGraphicsGetImageFromCurrentImageContext()!.cgImage!
        CGImageDestinationAddImage(destination, image, frameProps as CFDictionary)
        UIGraphicsEndImageContext()
        
        CGImageDestinationFinalize(destination)
        print("fileURL", fileURL)
    }
}
