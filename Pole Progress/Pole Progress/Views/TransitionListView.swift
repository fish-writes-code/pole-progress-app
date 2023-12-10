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
    @State private var showConfirmDelete: Bool = false
    @State private var transitionToDelete: PoleTransition?
    @State private var showStatusFilter: Bool = false
    @State private var selectedStatus: [Status] = Status.allCases
    
    var body: some View {
        NavigationStack {
            Button("Filter by Status", action: {showStatusFilter.toggle()}
            )
            if showStatusFilter {
                NavigationLink(destination: {
                    MultiSelectPickerView(selectedItems: $selectedStatus)
                        .navigationTitle("Filter by Status")
                }, label: {
                    // And then the label and dynamic number are displayed in the label. We don't need to include the chevron as it's done for us in the link
                    HStack {
                        Text("Select Status:")
                            .foregroundColor(Color(red: 0.4192, green: 0.2358, blue: 0.3450))
                        Spacer()
                        Image(systemName: "\($selectedStatus.count).circle")
                            .foregroundColor(Color(red: 0.4192, green: 0.2358, blue: 0.3450))
                            .font(.title2)
                    }
                }).frame(width: UIScreen.main.bounds.width * 0.65).padding(.top)
            } // end status filter if
            List {
                ForEach(filteredTransitions) { transition in 
                    NavigationLink {
                        TransitionDetailView(tController: transitionController, mController: moveController, transition: transition)
                    } label: {
                        TransitionRow(poleTransition: transition)
                    } // end NavLink
                    .swipeActions {
                        Button("Delete") {
                            showConfirmDelete = true
                            transitionToDelete = transition
                        /* Using .destructive role causes
                         weird UI glitches, so I'm using
                         tint instead */
                        }.tint(.red) // end delete button
                    } // end swipeActions
                } // end ForEach
            } // end List
            .alert("Do you really want to delete?", isPresented: $showConfirmDelete) {
                Button("Delete", role: .destructive) {
                    showConfirmDelete = false
                    transitionController.deleteTransition(transitionToDelete: transitionToDelete!)
                    transitionToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    showConfirmDelete = false
                    transitionToDelete = nil
                }
            } // end confirm delete dialog
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
    
    var filteredTransitions: [PoleTransition] {
        var temp = transitionController.transitions
        if selectedStatus.isEmpty || selectedStatus.count == 4 {
            return temp
        }
        if !(selectedStatus.isEmpty || selectedStatus.count == 4) {
            temp = temp.filter {
                selectedStatus.contains($0.status)
            }
        }
        return temp
    }
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
                    } // end HStack
                } // end VStack
            } // end if-else
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
            if !transition.name.isEmpty {
                HStack {
                    Text(transition.from.primaryName).font(.subheadline)
                    Image(systemName: "arrow.right").font(.subheadline)
                    Text(transition.to.primaryName).font(.subheadline)
                } // end HStack
            }
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
                    if transition.name.isEmpty {
                        HStack {
                            Text(transition.from.primaryName).font(.headline)
                            Image(systemName: "arrow.right").font(.headline)
                            Text(transition.to.primaryName).font(.headline)
                        }
                    } else {
                        Text(transition.name).font(.headline)
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
                    Section(header: Text("Name")) {
                        TextField("Optional", text: $transition.name)
                    }
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
