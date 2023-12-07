//
//  TransitionView.swift
//  Pole Progress
//
//  Created by hafernan on 12/6/23.
//

import SwiftUI

struct TransitionListView: View {
    @ObservedObject var transitionController = TransitionController()
    @ObservedObject var moveController = MoveController()
    @State private var transitionToAdd = PoleTransition()
    @State private var showEditor: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(transitionController.transitions) { transition in 
                    NavigationLink {
                        TransitionDetailView(tController: transitionController, mController: moveController, transition: transition)
                    } label: {
                        TransitionRow(poleTransition: transition)
                    }
                } // end ForEach
            } // end List
            .toolbar {
                ToolbarItem {
                    Button(action: { showEditor = true }) {
                        Label("Add Transiton", systemImage: "plus")
                    }
                }
            } // end toolbar
            .navigationTitle("All Transitions").navigationBarTitleDisplayMode(.inline)
        } // end NavStack
        .sheet(isPresented: $showEditor, onDismiss: {
            showEditor = false
            transitionToAdd = PoleTransition()
        }) {
            TransitionEditView(isNewTransition: true, transition: $transitionToAdd, transitionController: transitionController, moveController: moveController)
        } // end sheet
    } // end body
}

struct TransitionRow: View {
    var poleTransition: PoleTransition
    
    var body: some View {
        HStack {
            if poleTransition.name.isEmpty {
                Text(poleTransition.from.primaryName).font(.headline)
                Image(systemName: "arrow.right")
                Text(poleTransition.to.primaryName).font(.headline)
            } else {
                VStack(alignment: .leading, spacing: 4.0) {
                    Text(poleTransition.name).font(.headline)
                    HStack {
                        Text(poleTransition.from.primaryName).font(.caption)
                        Image(systemName: "arrow.right").font(.caption)
                        Text(poleTransition.to.primaryName).font(.caption)
                    }
                }
            }
        } // end HStack
    } // end body
}

struct TransitionDetailView: View {
    @ObservedObject var tController: TransitionController
    @ObservedObject var mController: MoveController
    @State var transition: PoleTransition
    @State var showEditor: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8.0) {
                HStack {
                    Text("Status:").font(.caption).bold()
                    Spacer()
                    Text(transition.status.description).font(.caption)
                }
                HStack {
                    Text("Last Trained:").font(.caption).bold()
                    Spacer()
                    Text(transition.lastTrainedString).font(.caption)
                }
                Spacer()
            } // end VStack
            .frame(width: UIScreen.main.bounds.width * 0.65).padding(.top)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(transition.from.primaryName).font(.headline)
                        Image(systemName: "arrow.right").font(.headline)
                        Text(transition.to.primaryName).font(.headline)
                    }
                }
                ToolbarItem {
                    Button(action: { showEditor = true }) {
                        Text("Edit")
                    }
                }
            } // end toolbar
        } // end NavStack
        .sheet(isPresented: $showEditor, onDismiss: { showEditor = false }) {
            TransitionEditView(isNewTransition: false, transition: $transition, transitionController: tController, moveController: mController)
        }
    } // end body
}

struct TransitionEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var transitionController: TransitionController
    @ObservedObject var moveController: MoveController
    
    @Binding var transition: PoleTransition
    
    @State private var transitionTo: PoleMove = PoleMove()
    @State private var transitionFrom: PoleMove = PoleMove()
    @State private var previouslyTrained: Bool = false
    @State private var lastTrainedDate: Date = Date()
    
    private var allowEditing: Bool = true
    private var isNewTransition: Bool = true
    
    init(isNewTransition: Bool, transition: Binding<PoleTransition>, transitionController: TransitionController, moveController: MoveController) {
        self._transition = transition
        self._transitionController = ObservedObject<TransitionController>(initialValue: transitionController)
        self._moveController = ObservedObject<MoveController>(initialValue: moveController)
        if let lastTrained = Binding<Date>(transition.lastTrained) {
            self._previouslyTrained = State(initialValue: true)
            self._lastTrainedDate = State(initialValue: lastTrained.wrappedValue)
        }
        if !isNewTransition {
            self._transitionFrom = State(initialValue: transition.wrappedValue.from)
            self._transitionTo = State(initialValue: transition.wrappedValue.to)
        } else if !moveController.moves.isEmpty {
            self._transitionFrom = State(initialValue: moveController.moves.first!)
            self._transitionTo = State(initialValue: moveController.moves.first!)
        } else {
            self.allowEditing = false
        }
        self.isNewTransition = isNewTransition
    }
    
    var body: some View {
        VStack {
            if !allowEditing {
                Text("Add moves before transitions")
            } else {
                Text(isNewTransition ? "Add a Transition" : "Edit Transition").font(.title)
                Form {
                    Section() {
                        Picker("Starting Move:", selection: $transitionFrom) {
                            ForEach(moveController.moves) { move in
                                Text(move.primaryName).tag(move as PoleMove)
                            }
                        }.disabled(!isNewTransition)
                        Picker("Ending Move:", selection: $transitionTo) {
                            ForEach(moveController.moves) { move in
                                Text(move.primaryName).tag(move as PoleMove)
                            }
                        }.disabled(!isNewTransition)
                    } // end moves section
                    Section() {
                        Picker("Status", selection: $transition.status) {
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
                } // end Form
                Button("Submit") {
                    if !previouslyTrained {
                        transition.lastTrained = nil
                    } else {
                        transition.lastTrained = lastTrainedDate
                    }
                    transition.to = transitionTo
                    transition.from = transitionFrom
                    transitionController.addOrUpdateTransition(transition: transition)
                    dismiss()
                } // end submit button
            } // end if-else
            Spacer()
        } // end VStack
        .padding()
    } // end body
}

#Preview {
    TransitionListView(transitionController: TransitionController(dataController: DataController.preview), moveController: MoveController(dataController: DataController.preview))
}
