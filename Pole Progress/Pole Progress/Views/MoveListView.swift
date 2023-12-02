//
//  MovesView.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//

import SwiftUI
import CoreData

struct MoveListView: View {
    @ObservedObject var moveController = MoveController()
    @State private var showConfirmDelete: Bool = false
    @State private var showAddMove: Bool = false
    
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
                    Button(action: { showAddMove = true }) {
                        Label("Add Move", systemImage: "plus")
                    }
                }
            }.navigationTitle("All Moves").navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showAddMove, onDismiss: { showAddMove = false }) {
            AddMoveView(controller: moveController)
        }
    }
}

struct MoveRow: View {
    let move: PoleMove
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(move.primaryName).font(.headline)
            Text(move.status.description).font(.caption)
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
                    Text(move.status.description).font(.caption)
                }
                HStack() {
                    Text("Last Trained:").font(.caption).bold()
                    Spacer()
                    Text(move.lastTrainedString).font(.caption)
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

struct AddMoveView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var controller: MoveController
    
    @State private var primaryName: String = ""
    @State private var otherNames: String = ""
    @State private var isSpinOnly: Bool = false
    @State private var status: Status = .toTry
    @State private var previouslyTrained: Bool = false
    @State private var lastTrainedDate: Date = Date()
    @State private var notes: String = ""
    
    var body: some View {
        VStack {
            Text("Add a Pole Move").font(.title)
            Form {
                Section(header: Text("Primary Name")) {
                    TextField("Required", text: $primaryName)
                }
                Section(header: Text("Other Names")) {
                    TextField("Other Names", text: $otherNames)
                }
                Section() {
                    Toggle(isOn: $isSpinOnly, label: {
                        Text("Spin Only?")
                    })
                }
                Section() {
                    Picker("Status", selection: $status) {
                        ForEach(Status.allCases) { status in
                            Text(status.description)
                        }
                    }
                }
                Section() {
                    Toggle(isOn: $previouslyTrained, label: {
                        Text("Previously Trained?")
                    })
                    DatePicker("Last Trained Date", selection: $lastTrainedDate, displayedComponents: [.date]).disabled(!previouslyTrained)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                }
            }
            Button("Submit") {
                let newMove = PoleMove(primaryName: primaryName, otherNames: otherNames, status: status, isSpinOnly: isSpinOnly, lastTrained: previouslyTrained ? lastTrainedDate : nil, notes: notes)
                controller.addOrUpdatePoleMove(move: newMove)
                dismiss()
            }
            Spacer()
        }.padding()
    }
}

#Preview {
    MoveListView(moveController: MoveController(dataController: DataController.preview))
}


