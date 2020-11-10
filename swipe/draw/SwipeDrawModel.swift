//
//  SwipeDrawModel.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 11/7/20.
//

import SwiftUI

protocol SwipeDrawModelDelegate: NSObjectProtocol {
    func onComplete(drawModel:SwipeDrawModel)
}

class SwipeDrawModel: ObservableObject {
    weak var delegate:SwipeDrawModelDelegate? = nil
    private var scale:CGFloat = 1.0
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
    
    func onEnded(_ location:CGPoint, scale:CGFloat) {
        self.scale = scale
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
        delegate?.onComplete(drawModel: self)
    }
    
    var path:CGPath {
        var path = Path()
        strokes.forEach {
            $0.append(to: &path)
            path.closeSubpath()
        }
        let cgPath = path.cgPath
        var xf = CGAffineTransform(scaleX: 1/scale, y: 1/scale)
        return cgPath.copy(using: &xf)!
    }
}


struct SwipeDrawModel_Previews: PreviewProvider {
    static var previews: some View {
        SwipeDraw(model: SwipeDrawModel(), dimension: CGSize(width: 640, height: 480))
    }
}
