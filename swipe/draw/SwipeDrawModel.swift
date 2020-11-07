//
//  SwipeDrawModel.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/7/20.
//

import SwiftUI

class SwipeDrawModel: ObservableObject {
    @Published var currentStroke = SwipeStroke()
    @Published var isDragging = false
    @Published var location = CGPoint.zero
    @Published var strokes = [SwipeStroke]()

    private var isUndoing = false
    @Published var undoCursor:Int = 0 {
        didSet {
            isUndoing = true
            isUndoing = false
        }
    }

    @Published var undoable = false
    @Published var redoable = false
    
    func updateUndoState() {
        undoable = undoCursor > 1
        redoable = undoCursor < strokes.count
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
    }}

