//
//  Pole_ProgressApp.swift
//  Pole Progress
//
//  Created by hafernan on 11/27/23.
//

import SwiftUI
import SwiftData

@main
struct Pole_ProgressApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Move.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MoveDetailsView()
        }
        .modelContainer(sharedModelContainer)
    }
}
