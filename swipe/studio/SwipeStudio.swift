//
//  SwipeStudio.swift
//  swipe_dev
//
//  Created by SATOSHI NAKAJIMA on 10/26/20.
//

import SwiftUI
import CoreData

#if os(macOS)
let s_previewHeight:CGFloat = 150
#else
let s_previewHeight:CGFloat = 100
#endif


public struct SwipeStudio: View {
    @State private var scenes = [SwipeScene]()
    /*
        SwipeScene(s_scriptEmpty),
        SwipeScene(s_scriptGen),
        SwipeScene(s_scriptSample),
    */
    let selectionColor = Color(Color.RGBColorSpace.sRGB, red: 0.0, green: 1.0, blue: 1.0, opacity: 1.0)
    let buttonColor = Color.blue

    init() {
        print("SwipeStudio init")
        let moc = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SceneObject")
        let sceneObjects = (try? moc.fetch(request) as? [SceneObject]) ?? [SceneObject]()
        print("sceneObjects", sceneObjects.count)
    }
    
    public var body: some View {
        let previewHeight:CGFloat = s_previewHeight
        #if os(macOS)
        return NavigationView {
            List(scenes.indices) { index in
                let model = SwipeCanvasModel(scene:scenes[index])
                let drawModel = SwipeDrawModel()
                NavigationLink(destination:
                                SwipeCanvas(model: model, drawModel:drawModel, previewHeight: previewHeight, selectionColor: selectionColor, buttonColor: buttonColor)
                ) {
                    Text("Sample")
                }
            }
        }
        #else
        return NavigationView {
            List {
                ForEach(scenes, id: \.id) { scene in
                    let model = SwipeCanvasModel(scene:scene)
                    let drawModel = SwipeDrawModel()
                    NavigationLink(destination:
                                    SwipeCanvas(model: model, drawModel:drawModel, previewHeight: previewHeight, selectionColor: selectionColor, buttonColor: buttonColor)
                    ) {
                        Text("Sample")
                    }
                }
                Button(action: {
                    let scene = SwipeScene(s_scriptEmpty)
                    scenes.append(scene)
                    guard let data = try? JSONSerialization.data(withJSONObject: scene.script, options: []) else {
                        print("###ERROR failed to serialize")
                        return
                    }
                    let moc = PersistenceController.shared.container.viewContext
                    let sceneObject = NSEntityDescription.insertNewObject(forEntityName: "SceneObject", into: moc) as! SceneObject
                    sceneObject.script = data
                    sceneObject.createdAt = Date()
                    sceneObject.updatedAt = sceneObject.createdAt
                    sceneObject.uuid = scene.uuid
                    do {
                        try moc.save()
                    } catch {
                        print("###ERROR failed to save", error)
                    }
                    
                }, label: {
                    Text("Add New Scene")
                })
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        #endif
    }
}

struct SwipeStudio_Previews: PreviewProvider {
    static var previews: some View {
        SwipeStudio()
    }
}
