//
//  SwipePage.swift
//  swipe20
//
//  Created by SATOSHI NAKAJIMA on 9/20/20.
//
import Cocoa

struct SwipeFrame {
    private let script:[String:Any]
    private let ids:[String]
    private let elements:[String:SwipeElement]
    var name:String? { script["name"] as? String } // name is optional
    
    init(_ script:[String:Any], base:SwipeFrame?) {
        self.script = script
        
        let elementScripts = script["elements"] as? [[String:Any]] ?? []
        var ids = [String]()
        var elements:[String:SwipeElement] = base?.elements ?? [:]
        for elementScript in elementScripts {
            if let id = elementScript["id"] as? String {
                ids.append(id)
                elements[id] = SwipeElement(elementScript, base:base?.elements[id])
            }
        }
        self.ids = base?.ids ?? ids
        self.elements = elements
    }
    
    func makeLayers() -> [CALayer] {
        return ids.map {
            elements[$0]!.makeLayer()
        }
    }
    
    func apply(to layers:[CALayer]) {
        for layer in layers {
            guard let name = layer.name,
                  let element = elements[name] else {
                return
            }
            _ = element.apply(to: layer)
        }
    }
}
