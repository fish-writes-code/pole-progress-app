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
                    TransitionListView(transitionController: transitionController, moveController: moveController)
                } label: {
                    Text("Pole Combos")
                }
            }).buttonStyle(.bordered)
        }
    }
}

#Preview {
    ContentView(
        moveController: MoveController(dataController: DataController.preview),
        transitionController: TransitionController(dataController: DataController.preview), 
        comboController: ComboController(dataController: DataController.preview))
}
