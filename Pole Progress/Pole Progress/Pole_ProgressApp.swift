//
//  Pole_ProgressApp.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//

import SwiftUI

@main
struct Pole_ProgressApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
