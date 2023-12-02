//
//  MovesView.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//

import SwiftUI
import CoreData

struct MoveListView: View {
    @StateObject var moveController = MoveController()
    @State private var showConfirmDelete: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(moveController.moves) { move in
                    NavigationLink {
                        MoveDetailsView(move: move)
                    } label: {
                        MoveRow(move: move)
                    }
                }.onDelete(perform: { indexSet in
                    showConfirmDelete = true
                }).confirmationDialog("Do you really want to delete?", isPresented: $showConfirmDelete) {
                    Button("Delete", role: .destructive) {
                        showConfirmDelete = false
                    }
                    Button("Cancel", role: .cancel) { 
                        showConfirmDelete = false
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {}) {
                        Label("Add Move", systemImage: "plus")
                    }
                }
            }.navigationTitle("All Moves").navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MoveRow: View {
    let move: PoleMove
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(move.primaryName).font(.headline)
            Text(move.getStatusString()).font(.caption)
        }
    }
}

struct MoveDetailsView: View {
    let move: PoleMove
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8.0) {
                if !move.otherNames.isEmpty {
                    HStack(alignment: .top) {
                        Text("Other Names:").font(.caption).bold().fixedSize()
                        Spacer()
                        Text(move.otherNames).font(.caption).fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    }
                }
                HStack() {
                    Text("Spin Only:").font(.caption).bold()
                    Spacer()
                    Text(move.isSpinOnly ? "Yes" : "No").font(.caption)
                }
                HStack() {
                    Text("Status:").font(.caption).bold()
                    Spacer()
                    Text(move.getStatusString()).font(.caption)
                }
                HStack() {
                    Text("Last Trained:").font(.caption).bold()
                    Spacer()
                    Text(move.getLastTrainedString()).font(.caption)
                }
                VStack(alignment: .leading, spacing: 4.0) {
                    Text("Notes:").font(.caption).bold()
                    Text(move.notes).font(.caption2).fixedSize(horizontal: false, vertical: true)
                }
            }.frame(width: UIScreen.main.bounds.width * 0.65).padding(.top)
            Spacer()
        }.toolbar {
            ToolbarItem {
                Button(action: {}) {
                    Text("Edit")
                }
            }
        }.navigationTitle(move.primaryName).navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MoveListView(moveController: MoveController(dataController: DataController.preview))
}


