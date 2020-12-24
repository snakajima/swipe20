//
//  SwipePage.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import CoreGraphics

/// A structure that describes a frame, which consists of a collection of elements
public struct SwipeFrame {
    //private let script:[String:Any]
    private(set) var ids:[String]
    private(set) var elements:[String:SwipeElement]
    let duration:Double?
    let name:String?
    public var isEmpty:Bool { elements.isEmpty }

    /// Initializes a frame with a specitifed description. base is a previous frame to animate from.
    init(_ script:[String:Any], base:SwipeFrame?) {
        //self.script = script
        self.duration = script["duration"] as? Double
        self.name = script["name"] as? String
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

    func inserted(element:SwipeElement) -> SwipeFrame {
        var frame = self
        frame.elements[element.id] = element
        guard ids.firstIndex(of: element.id) == nil else {
            print("##ERROR## duplicate id", element.id)
            return self
        }
        //print("appending", element.id)
        var ids = frame.ids
        ids.append(element.id)
        frame.ids = ids
        return frame
    }
    
    var script:[String:Any] {
        return [
            "elements": ids.map {
                elements[$0]!.script
            }
        ]
    }
}
