//
//  ContentView.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        MovesView()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
