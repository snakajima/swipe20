//
//  SwipeCanvas.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 10/3/20.
//

import SwiftUI

private let s_script:[String:Any] = [
    "backgroundColor":"#FFFFCC",
    "duration": Double(1.0),
    "animation": [
        "engine":"swipe"
    ],
    "frames":[[
        "elements":[[
            "id":"id0",
            "text":"Hello World",
            "foregroundColor":"gray",
            "x":200, "y":0, "w":300, "h":80,
            "animation": [
                "style":"summersault"
            ],
        ],[
            "id":"id1",
            "img":"pngwave.png",
            "x":20, "y":20, "w":180, "h":180,
            "anchorPoint":[0.5,0],
            "animation": [
                "style":"jump"
            ],
        ],[
            "id":"id2",
            "x":220, "y":100, "w":80, "h":80,
            "backgroundColor":"red",
            "cornerRadius": 20,
            "animation": [
                "style":"leap"
            ],
        ]]
    ]]
]

public struct SwipeCanvas: View {
    @State var frameIndex = 0
    @State var scene = SwipeScene(s_script)
    @State var selectedElement:SwipeElement?
    @State var cursorRect:CGRect = .zero
    @State var isDragging = false
    public var body: some View {
        return VStack(spacing:1) {
            SwipeSceneList(scene: $scene, frameIndex: $frameIndex)
            GeometryReader { geometry in
                ZStack {
                    SwipeView(scene: scene, frameIndex: $frameIndex)
                    if self.isDragging {
                        Path() { path in
                            var frame = self.cursorRect
                            frame.origin.y = geometry.size.height - frame.origin.y - frame.height
                            path.addRect(frame)
                        }
                        .stroke(lineWidth: 1.0)
                        .foregroundColor(.blue)
                    }
                }.gesture(DragGesture().onChanged { value in
                    if !self.isDragging {
                        var startLocation = value.startLocation
                        startLocation.y = geometry.size.height - startLocation.y
                        selectedElement = scene.hitTest(point: startLocation, frameIndex: frameIndex)
                        self.isDragging = true
                    
                    }
                    if let element = selectedElement {
                        var frame = element.frame
                        frame.origin.x += value.location.x - value.startLocation.x
                        frame.origin.y -= value.location.y - value.startLocation.y
                        self.cursorRect = frame
                    }
                }.onEnded({ value in
                    if let element = selectedElement {
                        let updatedElement = element.updated(frame: self.cursorRect)
                        self.scene = scene.updated(element: updatedElement, frameIndex: frameIndex)
                        self.selectedElement = nil
                        self.isDragging = false
                    }
                }))
            }
        }
    }
}

struct SwipeCanvas_Previews: PreviewProvider {
    static var previews: some View {
        SwipeCanvas()
    }
}

struct SwipeSceneList: View {
    @Binding var scene:SwipeScene
    @Binding var frameIndex:Int
    var body: some View {
        ScrollView (.horizontal, showsIndicators: true) {
            HStack(spacing:1) {
                ForEach(0..<scene.frameCount, id:\.self) { index in
                    HStack(spacing:1) {
                        VStack(spacing:1) {
                            ZStack {
                                SwipePreview(scene: scene, scale:0.2, frameIndex: index)
                                if index == frameIndex {
                                    Rectangle()
                                        .stroke(lineWidth: 1.0)
                                        .foregroundColor(.blue)
                                }
                            }
                            .frame(width:180)
                            .gesture(TapGesture().onEnded() {
                                frameIndex = index
                            })
                            HStack(spacing:4) {
                                Button(action: {
                                    scene = scene.frameDeleted(atIndex: index)
                                }) {
                                    SwipeSymbol.trash.frame(width:20, height:20)
                                }.disabled(scene.frameCount == 1)
                                Spacer()
                                Button(action: {
                                    print("star")
                                }) {
                                    SwipeSymbol.gearshape.frame(width:20, height:20)
                                }
                            }
                        }
                        Button(action:{
                            self.scene = scene.frameDuplicated(atIndex: index)
                            frameIndex = index + 1
                        }) {
                            SwipeSymbol.plus.frame(width:20, height:20)
                        }
                    }
                }
            }.frame(height:120)
        }
    }
}
