//
//  SwipeExporter.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/22/20.
//

import SwiftUI
import ImageIO
import CoreServices
import Photos

struct SwipeExporter: View {
    let scene: SwipeScene
    @Binding var snapshot: SwipeView.Snapshot?
    let fps = 30
    @State private var showingActivityViewController = false
    @State private var imageURL:URL? = nil
    
    var body: some View {
        VStack {
            Button(action: {
                export()
            }, label: {
                SwipeSymbol.action.frame(width:32, height:32)
                    .foregroundColor(.blue)
                    .padding(4)
            })
            Rectangle()
                .fill(Color.clear)
                .frame(height:32)
        }
        .sheet(isPresented: $showingActivityViewController, onDismiss: nil, content: {
            ActivityViewController(activityItems: [imageURL!])
        })
    }
    func export() {
        print("export")
        guard let folderURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            print("### ERRROR no document folder ###")
            return
        }
        let fileURL = folderURL.appendingPathComponent("swipeanime.gif")
        let fileProps = [kCGImagePropertyGIFDictionary:[kCGImagePropertyGIFLoopCount:0] as CFDictionary]
        let frameProps = [kCGImagePropertyGIFDictionary:[kCGImagePropertyGIFDelayTime:1.0/Double(fps)] as CFDictionary]
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypeGIF, (scene.frameCount - 1) * fps + 1, fileProps as CFDictionary) else {
            print("### ERROR can't create destination")
            return
        }
        
        func tick(step: Int) {
            let frameIndex = step / fps
            let ratio = Double(step % fps) / Double(fps)
            print("tick", step, frameIndex, ratio)
            snapshot = SwipeView.Snapshot(frameIndex: frameIndex, ratio: ratio, callback: { (osView, layer) in
                DispatchQueue.main.async {
                    UIGraphicsBeginImageContext(osView.bounds.size)
                    //let ctx = UIGraphicsGetCurrentContext()!
                    //layer.presentation()?.render(in: ctx)
                    osView.drawHierarchy(in: osView.bounds, afterScreenUpdates: false)
                    let image = UIGraphicsGetImageFromCurrentImageContext()!.cgImage!
                    CGImageDestinationAddImage(destination, image, frameProps as CFDictionary)
                    UIGraphicsEndImageContext()

                    if step < (scene.frameCount - 1) * fps {
                        tick(step: step + 1)
                    } else {
                        snapshot = nil
                        CGImageDestinationFinalize(destination)
                        print("fileURL", fileURL)
                        self.imageURL = fileURL
                        self.showingActivityViewController = true
                        /*
                        PHPhotoLibrary.shared().performChanges {
                            PHAssetCreationRequest.creationRequestForAssetFromImage(atFileURL: fileURL)
                        } completionHandler: { (saved, error) in
                            print("saved", saved)
                        }
                        */
                        //let av = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                        //UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
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
    }
}

/*
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
*/
