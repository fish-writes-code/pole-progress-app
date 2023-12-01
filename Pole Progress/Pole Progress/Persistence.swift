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
        
        let toTryMove = PoleMoveEntity(context: controller.container.viewContext)
        toTryMove.id = UUID()
        toTryMove.primary_name = "Forearm Ayesha"
        toTryMove.status = Status.toTry
        toTryMove.added_on = Date()
        
        let inProgressMove = PoleMoveEntity(context: controller.container.viewContext)
        inProgressMove.id = UUID()
        inProgressMove.primary_name = "Reiko"
        inProgressMove.other_names = "Foot Mount, Flying K"
        inProgressMove.status = Status.inProgress
        inProgressMove.added_on = Date()
        inProgressMove.last_trained = formatter.date(from: "11/3/2023")
        
        let solidMove = PoleMoveEntity(context: controller.container.viewContext)
        solidMove.id = UUID()
        solidMove.primary_name = "Gemini"
        solidMove.other_names = "Outside Leg Hang"
        solidMove.status = Status.solid
        solidMove.added_on = Date()
        solidMove.last_trained = formatter.date(from: "24/11/2023")
        solidMove.notes = "For some reason, whenever I take a long break from pole, this one always gets really shaky. It's like I forget how to grip with the knee pit."
        
        let blockedMove = PoleMoveEntity(context: controller.container.viewContext)
        blockedMove.id = UUID()
        blockedMove.primary_name = "Twisted Poisson"
        blockedMove.other_names = "Poisson, Twisted Fish, Fish, Reverse Poisson, French Fish, Reverse French Fish"
        blockedMove.status = Status.blocked
        blockedMove.added_on = Date()
        blockedMove.last_trained = formatter.date(from: "2/9/2022")
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
