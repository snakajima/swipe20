//
//  SwipeDrawModel.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/7/20.
//

import SwiftUI

class SwipeDrawModel: ObservableObject {
    @Published var currentStroke = SwipeStroke()
    @Published var strokes = [SwipeStroke]()

    func onChanged(_ location:CGPoint) {
        currentStroke.points.append(location)
    }
    func onEnded(_ location:CGPoint) {
        strokes.append(currentStroke)
        currentStroke = SwipeStroke()
    }
    
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


struct SwipeDrawModel_Previews: PreviewProvider {
    static var previews: some View {
        SwipeDraw()
    }
}
