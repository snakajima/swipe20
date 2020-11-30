//
//  SwipeCanvasModel.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 10/6/20.
//

import SwiftUI

class SwipeCanvasModel: NSObject, ObservableObject {
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
    @Published var isSelecting = false

    private var isUndoing = false
    private var undoCursor:Int {
        didSet {
            isUndoing = true
            self.scene = undoStack[undoCursor-1]
            isUndoing = false
            selectedElement = nil
        }
    }
    private var undoStack:[SwipeScene]

    @Published var undoable = false
    @Published var redoable = false
    @Published var scene:SwipeScene {
        didSet {
            if frameIndex >= scene.frameCount - 1 {
                frameIndex = scene.frameCount - 1
            }
            if !isUndoing {
                while(undoCursor < undoStack.count) {
                    undoStack.removeLast()
                }
                undoStack.append(scene)
                undoCursor = undoStack.count
            }
            updateUndoState()
        }
    }
    init(scene:SwipeScene) {
        self.scene = scene
        self.undoStack = [scene]
        self.undoCursor = undoStack.count
    }
    
    func updateUndoState() {
        undoable = undoCursor > 1
        redoable = undoCursor < undoStack.count
    }

    func undo() {
        if undoable {
            undoCursor -= 1
        }
    }
    
    func redo() {
        if redoable {
            undoCursor += 1
        }
    }

    var cursorCenter:CGPoint {
        CGPoint(x: cursorRect.origin.x + cursorRect.width / 2,
                y: cursorRect.origin.y + cursorRect.height / 2)
    }
    
    var scaledCursor:CGRect {
        let center = cursorCenter
        var xf = CGAffineTransform(translationX: center.x, y: center.y)
        xf = xf.scaledBy(x: abs(scale.x), y: abs(scale.y))
        xf = xf.translatedBy(x: -center.x, y: -center.y)
        return cursorRect.applying(xf)
    }
    
    func cursorTransform(center:CGPoint) -> CGAffineTransform {
        var xf = CGAffineTransform(translationX: center.x, y: center.y)
        xf = xf.rotated(by: -rotZ + (selectedElement?.rotZ ?? 0))
        xf = xf.translatedBy(x: -center.x, y: -center.y)
        return xf
    }
    
    func updateElement(frame:CGRect) {
        if let element = selectedElement {
            let updatedElement = element.updated(frame: frame)
            scene = scene.updated(element: updatedElement, frameIndex: frameIndex)
            selectedElement = updatedElement
        }
    }
    
    func updateElement(rotZ:CGFloat) {
        if let element = selectedElement {
            let updatedElement = element.updated(deltaRotZ: -rotZ)
            scene = scene.updated(element: updatedElement, frameIndex: frameIndex)
            selectedElement = updatedElement
        }
    }
}

extension SwipeCanvasModel : SwipeDrawModelDelegate {
    func onComplete(drawModel: SwipeDrawModel) {
        guard let path = drawModel.path else {
            return // empty
        }
        let frame = path.boundingBoxOfPath
        var xf = CGAffineTransform(translationX: -frame.minX, y: -frame.minY)
        var element = SwipeElement([:], id: UUID().uuidString, base: nil)
        element = element.updated(frame: frame)
        element = element.updated(path: path.copy(using: &xf)!)
        element = element.updated(animationStyle: drawModel.animationStyle)
        element = element.updated(strokeColor: drawModel.strokeColor, lineWidth: drawModel.lineWidth)
        scene = scene.inserted(element: element, atFrameIndex: frameIndex)
    }
}
