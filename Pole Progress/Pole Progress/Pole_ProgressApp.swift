//
//  Pole_ProgressApp.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//

import SwiftUI

@main
struct Pole_ProgressApp: App {
    @Environment(\.scenePhase) var scenePhase
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        // saves if app is backgrounded
        .onChange(of: scenePhase) { oldScenePhase, newScenePhase in
            if newScenePhase == .background {
                persistenceController.save()
            }
        }
    }
}
