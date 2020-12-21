//
//  SwipeDocument.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 12/21/20.
//

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

struct SwipeDocument {
    private(set) var scenes:[SwipeScene]
    public let uuid:UUID // uniquely identify a scene object (CoreData prop)

    public init(_ script:[String:Any]?, uuid:UUID? = nil) {
        self.uuid = uuid ?? UUID()
        let scriptScenes = script?["scenes"] as? [[String:Any]] ?? []
        self.scenes = scriptScenes.map({ (script) -> SwipeScene in
            SwipeScene(script, uuid: uuid)
        })
    }

    var script:[String:Any] {
        let script:[String:Any] = [
            "scenes": scenes.map { $0.script }
        ]
        return script
    }
}
