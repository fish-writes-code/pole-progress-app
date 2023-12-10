//
//  ContentView.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var moveController = MoveController()
    @StateObject var transitionController = TransitionController()
    @StateObject var comboController = ComboController()
    
    var body: some View {
        NavigationStack {
            Button(action: {}, label: {
                NavigationLink {
                    MoveListView(moveController: moveController)
                } label: {
                    Text("Pole Moves")
                }
            }).buttonStyle(.bordered)
            Button(action: {}, label: {
                NavigationLink {
                    TransitionListView(transitionController: transitionController, moveController: moveController)
                } label: {
                    Text("Pole Transitions")
                }
            }).buttonStyle(.bordered)
            Button(action: {}, label: {
                NavigationLink {
                    ComboListView(comboController: comboController, transitionController: transitionController, moveController: moveController)
                } label: {
                    Text("Pole Combos")
                }
            }).buttonStyle(.bordered)
        }
    }
}


// The struct that the custom picker (button) opens which is minorly adapted from: https://gist.github.com/dippnerd/5841898c2cf945994ba85871446329fa
struct MultiSelectPickerView: View {
    // The list of items we want to show
    @State var allItems = Status.allCases
    // Binding to the selected items we want to track
    @Binding var selectedItems: [Status]

    var body: some View {
        Form {
            List {
                ForEach(allItems, id: \.self) { status in
                    Button(action: {
                        if self.selectedItems.contains(status) {
                            self.selectedItems.removeAll(where: { $0 == status })
                        } else {
                            self.selectedItems.append(status)
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                                .opacity(self.selectedItems.contains(status) ? 1.0 : 0.0)
                            Text(status.description)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

#Preview {
    ContentView(
        moveController: MoveController(dataController: DataController.preview),
        transitionController: TransitionController(dataController: DataController.preview), 
        comboController: ComboController(dataController: DataController.preview))
}
