//
//  SwipeStudio_LiteApp.swift
//  SwipeStudio Lite
//
//  Created by SATOSHI NAKAJIMA on 10/26/20.
//

import SwiftUI

@main
struct SwipeStudio_LiteApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
