//
//  SwipePage.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import CoreGraphics

/// A structure that describes a frame, which consists of a collection of elements
public struct SwipeFrame {
    private let script:[String:Any]
    let ids:[String]
    private(set) var elements:[String:SwipeElement]
    let duration:Double?
    var name:String? { script["name"] as? String } // name is optional

    /// Initializes a frame with a specitifed description. base is a previous frame to animate from.
    init(_ script:[String:Any], base:SwipeFrame?) {
        self.script = script
        self.duration = script["duration"] as? Double
        let elementScripts = script["elements"] as? [[String:Any]] ?? []
        var ids = [String]()
        var elements:[String:SwipeElement] = base?.elements ?? [:]
        for elementScript in elementScripts {
            if let id = elementScript["id"] as? String {
                ids.append(id)
                elements[id] = SwipeElement(elementScript, id:id, base:base?.elements[id])
            }
        }
        self.ids = base?.ids ?? ids
        self.elements = elements
    }
    
    func hitTest(point:CGPoint) -> SwipeElement? {
        for id in ids.reversed() {
            if let element = elements[id],
               element.hitTest(point: point) {
                return element
            }
        }
        return nil
    }
    
    func updated(element:SwipeElement) -> SwipeFrame {
        var frame = self
        frame.elements[element.id] = element
        return frame
    }
}
