//
//  ContentView.swift
//  Pole Progress
//
//  Created by hafernan on 11/27/23.
//

import SwiftUI
import SwiftData

struct MoveDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var moves: [Move]

    var body: some View {
        HStack {
            Text("Move: ")
        }
    }
}

#Preview {
    MoveDetailsView()
        .modelContainer(for: Move.self, inMemory: true)
}
