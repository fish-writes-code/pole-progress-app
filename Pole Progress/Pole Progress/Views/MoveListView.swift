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
    @State private var moveToAdd = PoleMove()
    @State private var showConfirmDelete: Bool = false
    @State private var showMoveEditor: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(moveController.moves) { move in
                    NavigationLink {
                        MoveDetailsView(move: move, controller: moveController)
                    } label: {
                        MoveRow(move: move)
                    }
                    
                }
                .onDelete(perform: { indexSet in
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
                    Button(action: { showMoveEditor = true }) {
                        Label("Add Move", systemImage: "plus")
                    }
                }
            }.navigationTitle("All Moves").navigationBarTitleDisplayMode(.inline)
        }.sheet(isPresented: $showMoveEditor, onDismiss: { showMoveEditor = false }) {
            EditMoveView(move: $moveToAdd, controller: moveController)
        }
    }
}

struct MoveRow: View {
    var move: PoleMove
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(move.primaryName).font(.headline)
            Text(move.status.description).font(.caption)
        }
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
            }
            .frame(width: UIScreen.main.bounds.width * 0.65).padding(.top)
            .toolbar {
                ToolbarItem {
                    Button(action: { showEditor = true }) {
                        Text("Edit")
                    }
                }
            }.navigationTitle(move.primaryName).navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showEditor, onDismiss: { showEditor = false }) {
            EditMoveView(move: $move, controller: controller)
        }
        
    }
}

struct EditMoveView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var controller: MoveController
    
    @Binding var move: PoleMove
    @State private var isNewMove: Bool = false
    @State private var previouslyTrained: Bool = false
    @State private var lastTrainedDate: Date = Date()
    
    init(move: Binding<PoleMove>, controller: MoveController) {
        self._move = move
        self._controller = ObservedObject<MoveController>(initialValue: controller)
        if let lastTrained = Binding<Date>(move.lastTrained) {
            self._previouslyTrained = State(initialValue: true)
            self._lastTrainedDate = State(initialValue: lastTrained.wrappedValue)
        }
    }

    
    var body: some View {
        VStack {
            Text("Add a Pole Move").font(.title)
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
                    Picker("Status", selection: $move.status) {
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
                    TextEditor(text: $move.notes)
                }
            }
            Button("Submit") {
                if !previouslyTrained {
                    move.lastTrained = nil
                }
                controller.addOrUpdatePoleMove(move: move)
                dismiss()
            }
            Spacer()
        }.padding()
    }
}

#Preview {
    MoveListView(moveController: MoveController(dataController: DataController.preview))
}


