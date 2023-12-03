//
//  ContentView.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        MoveListView(moveController: MoveController(move: nil, dataController: DataController.preview))
    }
}

#Preview {
    MoveListView(moveController: MoveController(move: nil, dataController: DataController.preview))
}
