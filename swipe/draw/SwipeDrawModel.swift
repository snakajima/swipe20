//
//  SwipeDrawModel.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/7/20.
//

import SwiftUI

class SwipeDrawModel: ObservableObject {
    private var allStrokes = [SwipeStroke]()
    @Published var strokes = [SwipeStroke]()
    @Published var currentStroke = SwipeStroke()
    @Published var undoable = false
    @Published var redoable = false
    private var undoCursor:Int = 0 {
        didSet {
            strokes = allStrokes
            while strokes.count > undoCursor {
                strokes.removeLast()
            }
            undoable = undoCursor > 0
            redoable = undoCursor < allStrokes.count
        }
    }

    func onChanged(_ location:CGPoint) {
        currentStroke.points.append(location)
    }
    
    func onEnded(_ location:CGPoint) {
        allStrokes = strokes
        allStrokes.append(currentStroke)
        undoCursor = allStrokes.count
        currentStroke = SwipeStroke()
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
}


struct SwipeDrawModel_Previews: PreviewProvider {
    static var previews: some View {
        SwipeDraw()
    }
}
