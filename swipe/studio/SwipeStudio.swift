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
    let viewContext = PersistenceController.shared.container.viewContext
    @State var scenes:[SwipeScene]
    /*
        SwipeScene(s_scriptEmpty),
        SwipeScene(s_scriptGen),
        SwipeScene(s_scriptSample),
    */
    let selectionColor = Color(Color.RGBColorSpace.sRGB, red: 0.0, green: 1.0, blue: 1.0, opacity: 1.0)
    let buttonColor = Color.blue

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
                .onDelete(perform: { indexSet in
                    indexSet.forEach { index in
                        let scene = scenes[index]
                        scenes.remove(at: index)
                        if let sceneObject = SceneObject.sceneObject(with: scene.uuid) {
                            viewContext.delete(sceneObject)
                            PersistenceController.shared.saveContext()
                        }
                    }
                })
                Button(action: {
                    let scene = SwipeScene(s_scriptEmpty)
                    scenes.append(scene)
                    guard let data = scene.scriptData else {
                        print("###ERROR failed to serialize")
                        return
                    }
                    let sceneObject = NSEntityDescription.insertNewObject(forEntityName: "SceneObject", into: viewContext) as! SceneObject
                    sceneObject.script = data
                    sceneObject.createdAt = Date()
                    sceneObject.updatedAt = sceneObject.createdAt
                    sceneObject.uuid = scene.uuid
                    PersistenceController.shared.saveContext()
                }, label: {
                    Text("Add New Scene")
                })
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        #endif
    }
}

extension SceneObject {
    static func sceneObject(with uuid:UUID) -> SceneObject? {
        let viewContext = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SceneObject")
        request.predicate = NSPredicate(format: "uuid = %@", argumentArray: [uuid])
        let sceneObjects = try? viewContext.fetch(request)
        guard let sceneObject = sceneObjects?.first as? SceneObject else {
            print("### Error failed to fetch object with uuid")
            return nil
        }
        return sceneObject
    }
}

struct SwipeStudio_Previews: PreviewProvider {
    static var previews: some View {
        SwipeStudio(scenes:[])
    }
}
