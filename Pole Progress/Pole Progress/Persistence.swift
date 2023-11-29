//
//  Persistence.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        let toTryMove = PoleMove(context: controller.container.viewContext)
        toTryMove.primary_name = "Forearm Ayesha"
        toTryMove.status = Status.toTry
        toTryMove.added_on = Date()
        
        let inProgressMove = PoleMove(context: controller.container.viewContext)
        inProgressMove.primary_name = "Reiko"
        inProgressMove.other_names = "Foot mount,flying K"
        inProgressMove.status = Status.inProgress
        inProgressMove.added_on = Date()
        inProgressMove.last_trained = formatter.date(from: "3/11/2023")
        
        let solidMove = PoleMove(context: controller.container.viewContext)
        solidMove.primary_name = "Gemini"
        solidMove.other_names = "Outside Leg Hang"
        solidMove.status = Status.solid
        solidMove.added_on = Date()
        solidMove.last_trained = formatter.date(from: "11/24/2023")
        
        let blockedMove = PoleMove(context: controller.container.viewContext)
        blockedMove.primary_name = "Twisted Poisson"
        blockedMove.other_names = "Poisson,Twisted Fish,Fish"
        blockedMove.status = Status.blocked
        blockedMove.added_on = Date()
        blockedMove.last_trained = formatter.date(from: "9/2/2022")
        blockedMove.notes = "attempted and failed from extended butterfly"
        
        return controller
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PoleProgressData")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }
}
