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
    
    var body: some View {
        NavigationStack {
            NavigationLink {
                MoveListView(moveController: moveController)
            } label: {
                Text("Pole Moves")
            }
            NavigationLink {
                TransitionListView(transitionController: transitionController, moveController: moveController)
            } label: {
                Text("Pole Transitions")
            }
        }
        
    }
}

#Preview {
    ContentView(moveController: MoveController(dataController: DataController.preview), transitionController: TransitionController(dataController: DataController.preview))
}
