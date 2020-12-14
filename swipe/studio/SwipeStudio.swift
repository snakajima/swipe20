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
    @FetchRequest(entity: SceneObject.entity(), sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: true)]) var sceneObjects:FetchedResults<SceneObject>
    @State private var selection: UUID? = nil
    
    public var body: some View {
        let previewHeight:CGFloat = s_previewHeight
        #if os(macOS)
        return NavigationView {
            List {
                ForEach(sceneObjects) { sceneObject in
                    let model = SwipeCanvasModel(scene:scenes[index])
                    let drawModel = SwipeDrawModel()
                    NavigationLink(destination:
                                    SwipeCanvas(model: model, drawModel:drawModel, previewHeight: previewHeight, selectionColor: selectionColor, buttonColor: buttonColor)
                    ) {
                        if let sceneObject = SceneObject.sceneObject(with: model.scene.uuid),
                           let thumbnail = sceneObject.thumbnail,
                           let image = UIImage(data: thumbnail) {
                            Text("image")
                        } else {
                            Text("Sample")
                        }
                    }
                }
            }
        }
        #else
        return NavigationView {
            List {
                ForEach(sceneObjects) { sceneObject in
                    NavigationLink(destination:
                                    SwipeCanvasHolder(sceneObject: sceneObject, previewHeight: previewHeight),
                                   tag: sceneObject.uuid!,
                                   selection: $selection
                    ) {
                        if let thumbnail = sceneObject.thumbnail,
                           let image = UIImage(data: thumbnail) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height:100)
                        } else {
                            Rectangle()
                                .foregroundColor(.black)
                                .frame(width:100/1080*1920, height:100)
                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    indexSet.forEach { index in
                        //let scene = scenes[index]
                        //scenes.remove(at: index)
                        viewContext.delete(sceneObjects[index])
                    }
                    PersistenceController.shared.saveContext()
                })
                Button(action: {
                    let scene = SwipeScene(UIDevice.current.userInterfaceIdiom == .phone
                        ? s_scriptEmptyPhone : s_scriptEmpty)
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
                    DispatchQueue.main.async {
                        selection = scene.uuid
                    }
                }, label: {
                    SwipeSymbol.plus.frame(width:32, height:32)
                        .foregroundColor(.accentColor)
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
        SwipeStudio()
    }
}
