//
//  SwipeCanvasModel.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 10/6/20.
//

import SwiftUI

class SwipeCanvasModel: ObservableObject {
    @Published var frameIndex = 0 {
        didSet {
            selectedElement = nil
        }
    }
    @Published var selectedElement:SwipeElement?
    @Published var cursorRect:CGRect = .zero
    @Published var scale = CGPoint(x: 1, y: 1)
    @Published var rotZ = CGFloat(0)
    @Published var isDragging = false
    @Published var scene:SwipeScene {
        didSet {
            if frameIndex >= scene.frameCount - 1 {
                frameIndex = scene.frameCount - 1
            }
        }
    }
    init(scene:SwipeScene) {
        self.scene = scene
    }

    var cursorCenter:CGPoint {
        CGPoint(x: cursorRect.origin.x + cursorRect.width / 2,
                y: cursorRect.origin.y + cursorRect.height / 2)
    }
    
    var scaledCursor:CGRect {
        let center = cursorCenter
        var xf = CGAffineTransform(translationX: center.x, y: center.y)
        xf = xf.scaledBy(x: scale.x, y: scale.y)
        xf = xf.translatedBy(x: -center.x, y: -center.y)
        return cursorRect.applying(xf)
    }
    
    var cursorPath:CGPath {
        let path = CGMutablePath()
        path.addRect(cursorRect)
        let center = cursorCenter
        var xf = CGAffineTransform(translationX: center.x, y: center.y)
        xf = xf.scaledBy(x: scale.x, y: scale.y)
        xf = xf.rotated(by: rotZ + (selectedElement?.rotZ ?? 0))
        xf = xf.translatedBy(x: -center.x, y: -center.y)
        return path.copy(using: &xf) ?? path
    }
    
    func updateElemen(frame:CGRect) {
        if let element = selectedElement {
            let updatedElement = element.updated(frame: frame)
            scene = scene.updated(element: updatedElement, frameIndex: frameIndex)
            selectedElement = updatedElement
        }
    }
    
    func updateElement(rotZ:CGFloat) {
        if let element = selectedElement {
            let updatedElement = element.updated(rotZ: -rotZ / .pi * 180)
            scene = scene.updated(element: updatedElement, frameIndex: frameIndex)
            selectedElement = updatedElement
        }
    }
}
