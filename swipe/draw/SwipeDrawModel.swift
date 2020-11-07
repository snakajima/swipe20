//
//  SwipeDrawModel.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/7/20.
//

import SwiftUI

class SwipeDrawModel: ObservableObject {
    @Published var currentStroke = SwipeStroke()
    private var allStrokes = [SwipeStroke]()
    @Published var strokes = [SwipeStroke]()

    func onChanged(_ location:CGPoint) {
        currentStroke.points.append(location)
    }
    func onEnded(_ location:CGPoint) {
        strokes.append(currentStroke)
        allStrokes = strokes
        undoCursor = strokes.count
        currentStroke = SwipeStroke()
        updateUndoState()
    }
    
    private var isUndoing = false
    private var undoCursor:Int = 0 {
        didSet {
            isUndoing = true
            isUndoing = false
            strokes = allStrokes
            while strokes.count > undoCursor {
                strokes.removeLast()
            }
            updateUndoState()
        }
    }

    @Published var undoable = false
    @Published var redoable = false
    
    func updateUndoState() {
        undoable = undoCursor > 0
        redoable = undoCursor < allStrokes.count
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


struct SwipeDrawModel_Previews: PreviewProvider {
    static var previews: some View {
        SwipeDraw()
    }
}
