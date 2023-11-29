//
//  MovesView.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//

import SwiftUI
import CoreData

struct MovesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PoleMove.primary_name, ascending: true)],
        animation: .default)
    private var moves: FetchedResults<PoleMove>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(moves) { move in
                    NavigationLink {
                        Text(move.primary_name)
                        LabeledContent("Other Names:", value: move.other_names)
                        LabeledContent("Status:", value: move.getStatusString())
                        LabeledContent("Notes:", value: move.notes)
                        LabeledContent("Last Trained On:", value: move.getLastTrainedString())
                    } label: {
                        Text(move.primary_name)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    EditButton()
//                }
                ToolbarItem {
                    Button(action: { addMove(primary_name: "new move") }) {
                        Label("Add Move", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addMove(primary_name: String) {
        withAnimation {
            let newMove = PoleMove(context: viewContext)
            newMove.primary_name = primary_name
            newMove.status = Status.toTry
            newMove.is_spin_only = false

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { moves[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    MovesView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

