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
        xf = xf.scaledBy(x: scale.x, y: scale.y)
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
            let updatedElement = element.updated(rotZ: -rotZ)
            scene = scene.updated(element: updatedElement, frameIndex: frameIndex)
            selectedElement = updatedElement
        }
    }
}

extension SwipeCanvasModel : SwipeDrawModelDelegate {
    func onComplete(drawModel: SwipeDrawModel) {
        let path = drawModel.path
        let frame = path.boundingBoxOfPath
        print("onComplete before", frameIndex, scene.frames[0].ids.count, scale)
        let script:[String:Any] = [
            "id":"id2",
            "x":frame.minX, "y":frame.minY,
            "w":frame.width, "h":frame.height,
            "backgroundColor":"yellow",
            "strokeColor":"blue",
            "lineWidth": 2,
            "fillColor": "yellow",
            "cornerRadius": 20,
            "animation": [
                "style":"jump"
            ],
        ]
            /*
            "id":UUID().uuidString,
            "x":frame.minX, "y":frame.minY,
            "w":frame.width, "h":frame.height,
            "backgroundColor":"red"
            */
        var element = SwipeElement(script, id: UUID().uuidString, base: nil)
        element = element.elementWithPath(path: drawModel.path)
        scene = scene.inserted(element: element, frameIndex: frameIndex)
        print("onComplete after", frameIndex, scene.frames[0].ids.count, scene.script)
    }
}
