//
//  DataController.swift
//  Pole Progress
//
//  Created by hafernan on 11/30/23.
//

import Foundation
import CoreData
import OrderedCollections

class DataController: NSObject, ObservableObject {
    @Published var movesStore: OrderedDictionary<UUID, PoleMove> = [:]
    
    var moves: [PoleMove] {
        Array(movesStore.values)
    }
    
    fileprivate var managedObjectContext: NSManagedObjectContext
    private let movesController: NSFetchedResultsController<PoleMoveEntity>
    
    override private init() {
        self.managedObjectContext = PersistenceController.shared.container.viewContext
        let moveFetchRequest: NSFetchRequest<PoleMoveEntity> = PoleMoveEntity.fetchRequest()
        
        moveFetchRequest.sortDescriptors = [NSSortDescriptor(key: "primary_move", ascending: true)]
        movesController = NSFetchedResultsController(
            fetchRequest: moveFetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        movesController.delegate = self
        try? movesController.performFetch()
        if let newMoves = movesController.fetchedObjects {
            self.movesStore = OrderedDictionary(uniqueKeysWithValues: newMoves.map({ ($0.id, PoleMove(move: $0)) }) )
        }
    }
    
    func saveData() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                NSLog("Unresolved error saving context: \(error), \(error.userInfo)")
            }
        }
    }
}

extension DataController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let newMoves = controller.fetchedObjects as? [PoleMoveEntity] {
            self.movesStore = OrderedDictionary(uniqueKeysWithValues: newMoves.map({ ($0.id, PoleMove(move: $0)) }) )
        }
    }
}
