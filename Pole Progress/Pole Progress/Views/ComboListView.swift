//
//  ComboListView.swift
//  Pole Progress
//
//  Created by hafernan on 12/8/23.
//

import SwiftUI

struct ComboListView: View {
    @ObservedObject var comboController = ComboController()
    @ObservedObject var transitionController = TransitionController()
    @ObservedObject var moveController = MoveController()
    
    @State var comboToAdd = PoleCombo()
    @State var showEditor: Bool = false
    @State var showConfirmDelete: Bool = false
    @State var comboToDelete: PoleCombo?
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(comboController.combos) { combo in
                    NavigationLink {
                        ComboDetailView(cController: comboController, mController: moveController, combo: combo)
                    } label: {
                        ComboRow(poleCombo: combo)
                    }
                } // end ForEach
            } // end List
            .toolbar {
                ToolbarItem {
                    Button(action: { showEditor = true }) {
                        Label("Add Combo", systemImage: "plus")
                    }
                }
            } // end toolbar
            .navigationTitle("Combos").navigationBarTitleDisplayMode(.inline)
        } // end NavStack
    } // end body
}

struct ComboRow: View {
    var poleCombo: PoleCombo
    var body: some View {
        VStack (alignment: .leading, spacing: 6.0) {
            Text(poleCombo.name).font(.headline).bold()
            let movesInCombo: String = String(poleCombo.moves.count)
            Text(movesInCombo + " moves").font(.caption)
        } // end VStack
    } // end body
}

struct ComboDetailView: View {
    @ObservedObject var cController: ComboController
    @ObservedObject var mController: MoveController
    
    @State var combo: PoleCombo
    @State var showEditor: Bool = false    
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Moves").font(.subheadline)) {
                        // empty
                        ForEach(combo.moves.indices, id: \.self) {  i in
                            Text(combo.moves[i].primaryName)
                            if combo.transitions.count > i && !combo.transitions[i].name.isEmpty {
                                Text(combo.transitions[i].name).font(.caption).padding(.leading, 10)
                            }
                        } // end ForEach
                    } // end moves section
                    Section() {
                        HStack() {
                            Text("Status:").bold()
                            Spacer()
                            Text(combo.status.description)
                        }
                    } // end Status section
                    Section() {
                        HStack() {
                            Text("Last Trained:").bold()
                            Spacer()
                            Text(combo.lastTrainedString)
                        }
                    } // end last trained section
                }.listStyle(.insetGrouped) // end List
            } // end VStack
            .toolbar {
                ToolbarItem {
                    Button(action: { showEditor = true }) {
                        Text("Edit")
                    }
                }
            } // end toolbar
            .navigationTitle(combo.name)
        } // end NavStack
    }
}

#Preview {
    ComboListView(comboController: ComboController(dataController: DataController.preview), transitionController: TransitionController(dataController: DataController.preview), moveController: MoveController(dataController: DataController.preview))
}
