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
    @State var showStatusFilter: Bool = false
    @State var selectedStatus: [Status] = Status.allCases
    
    
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
                ForEach(filteredCombos) { combo in
                    NavigationLink {
                        ComboDetailView(cController: comboController, mController: moveController, tController: transitionController, combo: combo)
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
        .sheet(isPresented: $showEditor, onDismiss: {
            showEditor = false
            comboToAdd = PoleCombo()
        }) {
            ComboEditView(controller: comboController, mController: moveController, tController: transitionController, combo: $comboToAdd, isNewCombo: true)
        }
    } // end body
    var filteredCombos: [PoleCombo] {
        var temp = comboController.combos
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
    @ObservedObject var tController: TransitionController
    
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
                    Button(action: {
                        showEditor = true
                    }) {
                        Text("Edit")
                    }
                }
            } // end toolbar
            .navigationTitle(combo.name)
        } // end NavStack
        .sheet(isPresented: $showEditor, onDismiss: {
            showEditor = false
        }) {
            ComboEditView(controller: cController, mController: mController, tController: tController, combo: $combo, isNewCombo: false)
        }
    }
}

struct ComboEditView : View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var controller: ComboController
    @ObservedObject var mController: MoveController
    @ObservedObject var tController: TransitionController
    
    @Binding var combo: PoleCombo
    
    @State private var moveSearch: String = ""
    @State private var isMoveSuggested: Bool = false
    
    @State private var selectedMoves: [PoleMove] = []
    
    @State private var previouslyTrained: Bool = false
    @State private var lastTrainedDate: Date = Date()
    
    var isNewCombo: Bool
    
    
    init(controller: ComboController, mController: MoveController, tController: TransitionController, combo: Binding<PoleCombo>, isNewCombo: Bool, action: ((String, Int) -> Void)? = nil) {
        self.controller = controller
        self.mController = mController
        self.tController = tController
        self._combo = combo
        self.isNewCombo = isNewCombo
        
        if !isNewCombo {
            self._selectedMoves = State(initialValue: combo.wrappedValue.moves.elements)
        }
        
        if let lastTrained = Binding<Date>(combo.lastTrained) {
            self._previouslyTrained = State(initialValue: true)
            self._lastTrainedDate = State(initialValue: lastTrained.wrappedValue)
        }
    }
    
    var body: some View {
        VStack {
            Text(isNewCombo ? "Add a Combo" : "Edit Combo").font(.title)
            Form {
                Section(header: Text("Name")) {
                    TextField("Required", text: $combo.name)
                }
                
                Section(header: Text("Moves")) {
                    TextField("Add a move", text: $moveSearch)
                        .onChange(of: moveSearch, {
                            if moveSearch.count != 0 {
                                self.isMoveSuggested = true
                            } else {
                                self.isMoveSuggested = false
                            }
                        })
                    if isMoveSuggested {
                        List {
                            ForEach(filteredMoves) { move in
                                Text(move.primaryName)
                                    .onTapGesture {
                                        selectedMoves.append(move)
                                        isMoveSuggested = false
                                        moveSearch = ""
                                    }
                            }.foregroundColor(.gray)
                        }
                    }
                    List {
                        ForEach(Array(zip(selectedMoves.indices, selectedMoves)), id: \.1.id) { (i, move) in
                            HStack {
                                Text(move.primaryName)
                                Image(systemName: "xmark.circle").onTapGesture( perform: {
                                    selectedMoves.remove(at: i)
                                })
                            }
                        } // end ForEach
                        .padding(2.0)
                    }
                }
                
                Section() {
                    Picker("Status", selection: $combo.status) {
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
                    combo.lastTrained = nil
                } else {
                    combo.lastTrained = lastTrainedDate
                }
//                controller.addOrUpdatePoleMove(move: move)
                dismiss()
            }
            Spacer()
        } // end VStack
    } // end body
    
    var filteredMoves: [PoleMove] {
        var temp = mController.moves
        if !moveSearch.isEmpty {
            temp = temp.filter {
                $0.allNamesArray.contains { name in name.range(of: moveSearch, options: .caseInsensitive) != nil }
            }
        }
        return temp
    }
}

#Preview {
    ComboListView(comboController: ComboController(dataController: DataController.preview), transitionController: TransitionController(dataController: DataController.preview), moveController: MoveController(dataController: DataController.preview))
}
