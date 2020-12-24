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
let s_previewHeightPhone:CGFloat = 60
#endif


public struct SwipeStudio: View {
    let viewContext = PersistenceController.shared.container.viewContext
    @FetchRequest(entity: SceneObject.entity(), sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: true)]) var sceneObjects:FetchedResults<SceneObject>
    @State private var selection: UUID? = nil
    
    public var body: some View {
        let previewHeight:CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? s_previewHeightPhone : s_previewHeight
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
                    //let scene = SwipeScene(UIDevice.current.userInterfaceIdiom == .phone
                    //    ? s_scriptEmptyPhone : s_scriptEmpty)
                    let scene = SwipeScene(s_scriptEmpty)
                    // NOTE: Store it as a single Scene document for now, assuming
                    // we will eventually support multi-scene document
                    let document = SwipeDocument(scenes: [scene], uuid:scene.uuid)
                    guard let data = document.scriptData else {
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
                if sceneObjects.isEmpty {
                    Text("empty documents").foregroundColor(.black)
                }
            } // List
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text("Documents"))
            Tutorial()
        }
        #endif
    }
    public struct Tutorial: View {
        public var body: some View {
            VStack(alignment: .leading) {
                Text("welcome")
            }.padding().background(
                Rectangle().foregroundColor(.white).shadow(radius: 5)
            )
        }
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
