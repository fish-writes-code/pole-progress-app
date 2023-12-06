//
//  DataController.swift
//  Pole Progress
//
//  Created by hafernan on 11/30/23.
//

import Foundation
import CoreData
import OrderedCollections

enum DataControllerType {
    case normal, preview, testing
}

class DataController: NSObject, ObservableObject {
    
    static let shared = DataController(type: .normal)
    static let preview = DataController(type: .preview)
    
    /** Ordered Dictionary of PoleMove structs.
     key: UUID,
     value: PoleMove (struct) */
    @Published var movesStore: OrderedDictionary<UUID, PoleMove> = [:]
    
    /** Array of PoleMove structs */
    var moves: [PoleMove] {
        Array(movesStore.values)
    }
    
    fileprivate var managedObjectContext: NSManagedObjectContext
    private let movesController: NSFetchedResultsController<PoleMoveEntity>
    
    private init(type: DataControllerType) {
        switch type {
            case .normal:
                let persistenceController = PersistenceController()
                self.managedObjectContext = persistenceController.context
            case .testing:
                let persistenceController = PersistenceController(inMemory: true)
                self.managedObjectContext = persistenceController.context
            case .preview:
                let persistenceController = PersistenceController(inMemory: true)
                self.managedObjectContext = persistenceController.context
        }
        
        let moveFetchRequest: NSFetchRequest<PoleMoveEntity> = PoleMoveEntity.fetchRequest()
        moveFetchRequest.sortDescriptors = [NSSortDescriptor(key: "primary_name", ascending: true)]
        movesController = NSFetchedResultsController(
            fetchRequest: moveFetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        if type == .preview { _loadPreviewData() }
        
        movesController.delegate = self
        try? movesController.performFetch()
        _mapPoleMoves(movesController.fetchedObjects)
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
    
    private func _loadPreviewData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        let toTryMove = PoleMoveEntity(context: managedObjectContext)
        toTryMove.id = UUID()
        toTryMove.primary_name = "Forearm Ayesha"
        toTryMove.is_spin_only = false
        toTryMove.status = Status.toTry
        toTryMove.added_on = Date()
        
        let inProgressMove = PoleMoveEntity(context: managedObjectContext)
        inProgressMove.id = UUID()
        inProgressMove.primary_name = "Reiko"
        inProgressMove.other_names = "Foot Mount, Flying K"
        inProgressMove.status = Status.inProgress
        inProgressMove.is_spin_only = false
        inProgressMove.added_on = Date()
        inProgressMove.last_trained = formatter.date(from: "11/3/2023")
        
        let solidMove = PoleMoveEntity(context: managedObjectContext)
        solidMove.id = UUID()
        solidMove.primary_name = "Gemini"
        solidMove.other_names = "Outside Leg Hang"
        solidMove.status = Status.solid
        solidMove.is_spin_only = false
        solidMove.added_on = Date()
        solidMove.last_trained = formatter.date(from: "24/11/2023")
        solidMove.notes = "For some reason, whenever I take a long break from pole, this one always gets really shaky. It's like I forget how to grip with the knee pit."
        
        let blockedMove = PoleMoveEntity(context: managedObjectContext)
        blockedMove.id = UUID()
        blockedMove.primary_name = "Twisted Poisson"
        blockedMove.other_names = "Poisson, Twisted Fish, Fish, Reverse Poisson, French Fish, Reverse French Fish"
        blockedMove.status = Status.blocked
        blockedMove.is_spin_only = false
        blockedMove.added_on = Date()
        blockedMove.last_trained = formatter.date(from: "2/9/2022")
        blockedMove.notes = "attempted and failed from extended butterfly"
        
        let spinOnlyMove = PoleMoveEntity(context: managedObjectContext)
        spinOnlyMove.id = UUID()
        spinOnlyMove.primary_name = "Pencil Spin"
        spinOnlyMove.other_names = ""
        spinOnlyMove.is_spin_only = true
        spinOnlyMove.status = Status.solid
        spinOnlyMove.added_on = Date()
        spinOnlyMove.last_trained = formatter.date(from: "20/7/2023")
        spinOnlyMove.notes = "good conditioning move"
        
        try? self.managedObjectContext.save()
    }
}

extension DataController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        _mapPoleMoves(controller.fetchedObjects as? [PoleMoveEntity])
    }
    
    private func fetchFirst<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate?) -> Result<T?, Error> {
        let request = objectType.fetchRequest()
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try managedObjectContext.fetch(request) as? [T]
            return .success(result?.first)
        } catch {
            return .failure(error)
        }
    }
    
    /** get all pole moves */
    func fetchPoleMoves(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) {
        if let predicate = predicate {
            movesController.fetchRequest.predicate = predicate
        }
        if let sortDescriptors = sortDescriptors {
            movesController.fetchRequest.sortDescriptors = sortDescriptors
        }
        try? movesController.performFetch()
        _mapPoleMoves(movesController.fetchedObjects)
    }
    
    func resetPoleMoveFetch() {
        movesController.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "primary_name", ascending: true)]
        movesController.fetchRequest.predicate = nil
        try? movesController.performFetch()
        _mapPoleMoves(movesController.fetchedObjects)
        
    }
    
    /** add or update pole move */
    func updatePoleMove(moveStruct: PoleMove) {
        let predicate = NSPredicate(format: "id = %@", moveStruct.id as CVarArg)
        let result = fetchFirst(PoleMoveEntity.self, predicate: predicate)
        let moveEntity: PoleMoveEntity
        switch result {
        case .success(let managedObject):
            if managedObject != nil {
                moveEntity = managedObject!
            } else {
                moveEntity = PoleMoveEntity(context: managedObjectContext)
            }
            
            moveEntity.id = moveStruct.id
            moveEntity.primary_name = moveStruct.primaryName
            moveEntity.other_names = moveStruct.otherNames
            moveEntity.status = moveStruct.status
            moveEntity.is_spin_only = moveStruct.isSpinOnly
            moveEntity.notes = moveStruct.notes
            moveEntity.last_trained = moveStruct.lastTrained
            moveEntity.added_on = moveStruct.addedOn
            
        case .failure(_):
            print("Couldn't fetch PoleMoveEntity to save")
        }
        
        saveData()
        
    }
    
    func deletePoleMove(move: PoleMove) {
        let predicate = NSPredicate(format: "id = %@", move.id as CVarArg)
            let result = fetchFirst(PoleMoveEntity.self, predicate: predicate)
            switch result {
            case .success(let managedObject):
                if let moveEntity = managedObject {
                    managedObjectContext.delete(moveEntity)
                }
            case .failure(_):
                print("Couldn't fetch PoleMoveEntity to save")
            }
            saveData()
    }

    
    /** Utility function that maps fetched PoleMove structs to PoleMoveEntity objects */
    private func _mapPoleMoves(_ newMoves: [PoleMoveEntity]?) {
        if let newMoves = newMoves {
            self.movesStore = OrderedDictionary(uniqueKeysWithValues: newMoves.map({ ($0.id, PoleMove(move: $0)) }) )
        }
    }
}
