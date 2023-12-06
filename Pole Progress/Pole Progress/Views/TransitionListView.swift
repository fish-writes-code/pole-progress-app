//
//  TransitionView.swift
//  Pole Progress
//
//  Created by hafernan on 12/6/23.
//

import SwiftUI

struct TransitionListView: View {
    @StateObject var transitionController = TransitionController()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        NavigationStack {
            List {
                ForEach(transitionController.transitions) { transition in 
                    NavigationLink {
                        Text("A transition")
                    } label: {
                        Text("A Label")
                    }
                } // end ForEach
            } // end List
        } // end NavStack
    }
}

struct TransitionRow: View {
    var moveTransition: MoveTransition
    
    var body: some View {
        HStack {
            Text(moveTransition.from.primaryName)
            Text(moveTransition.to.primaryName)
        } // end HStack
    } // end body
}

#Preview {
    TransitionListView(transitionController: TransitionController(dataController: DataController.preview))
}
