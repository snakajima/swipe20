//
//  SwipeExporter.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/22/20.
//

import SwiftUI
import ImageIO
import MobileCoreServices
import Photos

struct SwipeExporter: View {
    let scene: SwipeScene
    @Binding var snapshot: SwipeView.Snapshot?
    
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
        let fileProps = [kCGImagePropertyGIFDictionary:[kCGImagePropertyGIFLoopCount:0] as CFDictionary]
        let frameProps = [kCGImagePropertyGIFDictionary:[kCGImagePropertyGIFDelayTime:1.0/30.0] as CFDictionary]
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypeGIF, 31, fileProps as CFDictionary) else {
            print("### ERROR can't create destination")
            return
        }
        
        func tick(step: Double) {
            snapshot = SwipeView.Snapshot(frameIndex: 0, ratio: step / 30.0, callback: { (osView, layer) in
                print("callbacked", step)
                DispatchQueue.main.async {
                    UIGraphicsBeginImageContext(osView.bounds.size)
                    //let ctx = UIGraphicsGetCurrentContext()!
                    //layer.presentation()?.render(in: ctx)
                    osView.drawHierarchy(in: osView.bounds, afterScreenUpdates: false)
                    let image = UIGraphicsGetImageFromCurrentImageContext()!.cgImage!
                    CGImageDestinationAddImage(destination, image, frameProps as CFDictionary)
                    UIGraphicsEndImageContext()

                    if step < 30 {
                        tick(step: step + 1)
                    } else {
                        snapshot = nil
                        CGImageDestinationFinalize(destination)
                        print("fileURL", fileURL)
                        
                        PHPhotoLibrary.shared().performChanges {
                            PHAssetCreationRequest.creationRequestForAssetFromImage(atFileURL: fileURL)
                        } completionHandler: { (saved, error) in
                            print("saved", saved)
                        }

                    }
                }
            })
        }
        tick(step: 0)
        /*
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
        */
        print("fileURL", fileURL)
    }
}
