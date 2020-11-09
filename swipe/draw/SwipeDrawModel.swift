//
//  SwipeDrawModel.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/7/20.
//

import SwiftUI

protocol SwipeDrawModelDelegate: NSObjectProtocol {
    func onComplete()
}

class SwipeDrawModel: ObservableObject {
    weak var delegate:SwipeDrawModelDelegate? = nil
    private var allStrokes = [SwipeStroke]()
    @Published var strokes = [SwipeStroke]()
    @Published var currentStroke = SwipeStroke()
    @Published var undoable = false
    @Published var redoable = false
    @Published var isActive = false {
        didSet {
            if isActive {
                undoCursor = 0
                allStrokes.removeAll()
            }
        }
    }
    
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
    
    func activate() {
        isActive = true
    }
    
    func done() {
        isActive = false
        delegate?.onComplete()
    }
}


struct SwipeDrawModel_Previews: PreviewProvider {
    static var previews: some View {
        SwipeDraw(model: SwipeDrawModel())
    }
}
