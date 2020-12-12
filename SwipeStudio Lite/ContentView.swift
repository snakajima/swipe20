//
//  ContentView.swift
//  SwipeStudio Lite
//
//  Created by SATOSHI NAKAJIMA on 10/26/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        SwipeStudio()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
