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
    @State private var moveToAdd = PoleMove()
    @State private var showConfirmDelete: Bool = false
    @State private var moveToDelete: PoleMove?
    @State private var showMoveEditor: Bool = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredMoves) { move in
                    NavigationLink {
                        MoveDetailsView(move: move, controller: moveController)
                    } label: {
                        MoveRow(move: move)
                    } // end NavigationLink
                    .swipeActions {
                        Button("Delete") {
                            showConfirmDelete = true
                            moveToDelete = move
                        /* Using .destructive role causes
                         weird UI glitches, so I'm using
                         tint instead */
                        }.tint(.red) // end delete button
                    } // end swipeActions
                } // end moves foreach
            } // end list
            .searchable(text: $searchText, prompt: Text("Search by name"))
            .alert("Do you really want to delete? This will also delete ALL associated transitions!", isPresented: $showConfirmDelete) {
                Button("Delete", role: .destructive) {
                    showConfirmDelete = false
                    moveController.deletePoleMove(moveToDelete!)
                    moveToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    showConfirmDelete = false
                    moveToDelete = nil
                }
            } // end confirm delete dialog
            .toolbar {
                ToolbarItem {
                    Button(action: { showMoveEditor = true }) {
                        Label("Add Move", systemImage: "plus")
                    }
                }
            } // end toolbar
            .navigationTitle("All Moves").navigationBarTitleDisplayMode(.inline)
        } // end NavigationStack
        .sheet(isPresented: $showMoveEditor, onDismiss: {
            showMoveEditor = false
            moveToAdd = PoleMove()
        }) {
            EditMoveView(move: $moveToAdd, isNewMove: true, controller: moveController)
        }
    } // end body
    
    var filteredMoves: [PoleMove] {
        if searchText.isEmpty {
            return moveController.moves
        } else {
            return moveController.moves.filter {
                $0.allNamesArray.contains { name in name.range(of: searchText, options: .caseInsensitive) != nil }
            }
        }
    }
} // end MoveListView

struct MoveRow: View {
    var move: PoleMove
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(move.primaryName).font(.headline)
            if !move.otherNames.isEmpty {
                Text(move.otherNames).font(.caption)
            }
        }.padding(.vertical, 10.0)
    }
}

struct MoveDetailsView: View {
    @State var move: PoleMove
    @State var showEditor: Bool = false
    @ObservedObject var controller: MoveController
    
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
                    Text("Spotter Required:").font(.caption).bold()
                    Spacer()
                    Text(move.spotterRequired ? "Yes" : "No").font(.caption)
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
                Spacer()
            } // end VStack
            .frame(width: UIScreen.main.bounds.width * 0.65).padding(.top)
            .toolbar {
                ToolbarItem {
                    Button(action: { showEditor = true }) {
                        Text("Edit")
                    }
                }
            } // end toolbar
            .navigationTitle(move.primaryName).navigationBarTitleDisplayMode(.inline)
        } // end NavigationStack
        .sheet(isPresented: $showEditor, onDismiss: { showEditor = false }) {
            EditMoveView(move: $move, isNewMove: false, controller: controller)
        }
    } // end body
}

struct EditMoveView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var controller: MoveController
    
    @Binding var move: PoleMove
    @State private var previouslyTrained: Bool = false
    @State private var lastTrainedDate: Date = Date()
    
    private var isNewMove: Bool = false
    
    init(move: Binding<PoleMove>, isNewMove: Bool, controller: MoveController) {
        self._move = move
        self._controller = ObservedObject<MoveController>(initialValue: controller)
        if let lastTrained = Binding<Date>(move.lastTrained) {
            self._previouslyTrained = State(initialValue: true)
            self._lastTrainedDate = State(initialValue: lastTrained.wrappedValue)
        }
        self.isNewMove = isNewMove
    }

    
    var body: some View {
        VStack {
            Text(isNewMove ? "Add a Pole Move" : "Edit Pole Move").font(.title)
            Form {
                Section(header: Text("Primary Name")) {
                    TextField("Required", text: $move.primaryName)
                }
                Section(header: Text("Other Names")) {
                    TextField("Other Names", text: $move.otherNames)
                }
                Section() {
                    Toggle(isOn: $move.isSpinOnly, label: {
                        Text("Spin Only?")
                    })
                }
                Section() {
                    Toggle(isOn: $move.spotterRequired, label: {
                        Text("Spotter Required?")
                    })
                }
                Section() {
                    Picker("Status", selection: $move.status) {
                        ForEach(Status.allCases) { status in
                            Text(status.description)
                        }
                    }
                } // end status section
                Section() {
                    Toggle(isOn: $previouslyTrained, label: {
                        Text("Previously Trained?")
                    })
                    DatePicker("Last Trained Date", selection: $lastTrainedDate, displayedComponents: [.date]).disabled(!previouslyTrained)
                } // end previously trained section
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $move.notes)
                }
            } // end form
            Button("Submit") {
                if !previouslyTrained {
                    move.lastTrained = nil
                } else {
                    move.lastTrained = lastTrainedDate
                }
                controller.addOrUpdatePoleMove(move: move)
                dismiss()
            }
            Spacer()
        } // end VStack
        .padding()
    } // end body
}

#Preview {
    MoveListView(moveController: MoveController(dataController: DataController.preview))
}


