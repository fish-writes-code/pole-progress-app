//
//  ContentView.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PoleMove.primary_name, ascending: true)],
        animation: .default)
    private var moves: FetchedResults<PoleMove>
    
    var body: some View {
        MovesView()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
