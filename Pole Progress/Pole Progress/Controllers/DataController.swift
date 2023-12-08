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
    @Published var transitionsStore: OrderedDictionary<UUID, PoleTransition> = [:]
    @Published var combosStore: OrderedDictionary<UUID, PoleCombo> = [:]
    
    /** Array of PoleMove structs */
    var moves: [PoleMove] {
        Array(movesStore.values)
    }
    
    var transitions: [PoleTransition] {
        Array(transitionsStore.values)
    }
    
    var combos: [PoleCombo] {
        Array(combosStore.values)
    }
    
    fileprivate var managedObjectContext: NSManagedObjectContext
    private let movesController: NSFetchedResultsController<PoleMoveEntity>
    private let transitionsController: NSFetchedResultsController<TransitionEntity>
    private let combosController: NSFetchedResultsController<ComboEntity>
    
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
        
        let transitionFetchRequest: NSFetchRequest<TransitionEntity> = TransitionEntity.fetchRequest()
        transitionFetchRequest.sortDescriptors = [NSSortDescriptor(key: "added_on", ascending: false)]
        transitionsController = NSFetchedResultsController(
            fetchRequest: transitionFetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        let comboFetchRequest: NSFetchRequest<ComboEntity> = ComboEntity.fetchRequest()
        comboFetchRequest.sortDescriptors = [NSSortDescriptor(key: "added_on", ascending: false)]
        combosController = NSFetchedResultsController(
            fetchRequest: comboFetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        if type == .preview { _loadPreviewData() }
        
        movesController.delegate = self
        try? movesController.performFetch()
        _mapPoleMoves(movesController.fetchedObjects)
        
        transitionsController.delegate = self
        try? transitionsController.performFetch()
        _mapTransitions(transitionsController.fetchedObjects)
        
        combosController.delegate = self
        try? combosController.performFetch()
        _mapCombos(combosController.fetchedObjects)
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
        formatter.dateFormat = "MM/dd/yyyy"
        
        let ayesha = PoleMoveEntity(context: managedObjectContext)
        ayesha.id = UUID()
        ayesha.primary_name = "Forearm Ayesha"
        ayesha.is_spin_only = false
        ayesha.spotter_required = true
        ayesha.status = Status.toTry
        ayesha.added_on = Date()
        
        let reiko = PoleMoveEntity(context: managedObjectContext)
        reiko.id = UUID()
        reiko.primary_name = "Reiko"
        reiko.other_names = "Foot Mount, Flying K"
        reiko.status = Status.inProgress
        reiko.is_spin_only = false
        reiko.spotter_required = false
        reiko.added_on = Date()
        reiko.last_trained = formatter.date(from: "3/11/2023")
        
        let scorpio = PoleMoveEntity(context: managedObjectContext)
        scorpio.id = UUID()
        scorpio.primary_name = "Scorpio"
        scorpio.other_names = "Inside Leg Hang"
        scorpio.status = Status.inProgress
        scorpio.is_spin_only = false
        scorpio.spotter_required = false
        scorpio.added_on = Date()
        scorpio.last_trained = formatter.date(from: "11/24/2023")
        
        let gemini = PoleMoveEntity(context: managedObjectContext)
        gemini.id = UUID()
        gemini.primary_name = "Gemini"
        gemini.other_names = "Outside Leg Hang"
        gemini.status = Status.solid
        gemini.is_spin_only = false
        gemini.spotter_required = false
        gemini.added_on = Date()
        gemini.last_trained = formatter.date(from: "11/24/2023")
        gemini.notes = "For some reason, whenever I take a long break from pole, this one always gets really shaky. It's like I forget how to grip with the knee pit."
        
        let jasmine = PoleMoveEntity(context: managedObjectContext)
        jasmine.id = UUID()
        jasmine.primary_name = "Jasmine"
        jasmine.status = Status.solid
        jasmine.is_spin_only = false
        jasmine.spotter_required = false
        jasmine.added_on = Date()
        jasmine.last_trained = formatter.date(from: "12/4/2023")
        
        let poisson = PoleMoveEntity(context: managedObjectContext)
        poisson.id = UUID()
        poisson.primary_name = "Twisted Poisson"
        poisson.other_names = "Poisson, Twisted Fish, Fish, Reverse Poisson, French Fish, Reverse French Fish"
        poisson.status = Status.blocked
        poisson.is_spin_only = false
        poisson.spotter_required = true
        poisson.added_on = Date()
        poisson.last_trained = formatter.date(from: "9/2/2022")
        poisson.notes = "attempted and failed from extended butterfly"
        
        let pencil = PoleMoveEntity(context: managedObjectContext)
        pencil.id = UUID()
        pencil.primary_name = "Pencil Spin"
        pencil.other_names = ""
        pencil.is_spin_only = true
        pencil.spotter_required = false
        pencil.status = Status.solid
        pencil.added_on = Date()
        pencil.last_trained = formatter.date(from: "7/20/2023")
        pencil.notes = "good conditioning move"
        
        let cupid = PoleMoveEntity(context: managedObjectContext)
        cupid.id = UUID()
        cupid.primary_name = "Cupid"
        cupid.status = Status.inProgress
        cupid.is_spin_only = false
        cupid.spotter_required = false
        cupid.added_on = Date()
        cupid.last_trained = formatter.date(from: "7/21/2023")
        
        let solidTransition = TransitionEntity(context: managedObjectContext)
        solidTransition.id = UUID()
        solidTransition.added_on = Date()
        solidTransition.status = Status.solid
        solidTransition.from = pencil
        solidTransition.to = gemini
        solidTransition.last_trained = formatter.date(from: "6/18/2022")
        
        let inProgressTransition = TransitionEntity(context: managedObjectContext)
        inProgressTransition.id = UUID()
        inProgressTransition.added_on = formatter.date(from: "12/5/2023")!
        inProgressTransition.status = Status.inProgress
        inProgressTransition.from = reiko
        inProgressTransition.to = cupid
        inProgressTransition.last_trained = formatter.date(from: "3/11/2023")
        
        let blockedTransition = TransitionEntity(context: managedObjectContext)
        blockedTransition.id = UUID()
        blockedTransition.added_on = formatter.date(from: "12/3/2023")!
        blockedTransition.status = Status.blocked
        blockedTransition.from = gemini
        blockedTransition.to = poisson
        
        let cupidtoJasmine = TransitionEntity(context: managedObjectContext)
        cupidtoJasmine.id = UUID()
        cupidtoJasmine.added_on = Date()
        cupidtoJasmine.status = Status.inProgress
        cupidtoJasmine.from = cupid
        cupidtoJasmine.to = jasmine
        cupidtoJasmine.last_trained = formatter.date(from: "7/21/2023")
        
        let legHangSwitch = TransitionEntity(context: managedObjectContext)
        legHangSwitch.id = UUID()
        legHangSwitch.name = "Leg Hang Switch"
        legHangSwitch.added_on = formatter.date(from: "12/3/2023")!
        legHangSwitch.status = Status.inProgress
        legHangSwitch.from = gemini
        legHangSwitch.to = scorpio
        
        let torsoSwitch = TransitionEntity(context: managedObjectContext)
        torsoSwitch.id = UUID()
        torsoSwitch.name = "Torso Switch"
        torsoSwitch.added_on = formatter.date(from: "12/3/2023")!
        torsoSwitch.status = Status.inProgress
        torsoSwitch.from = gemini
        torsoSwitch.to = scorpio
        
        let cupidCombo = ComboEntity(context: managedObjectContext)
        cupidCombo.id = UUID()
        cupidCombo.name = "Cupid to Jasmine"
        cupidCombo.moves = NSOrderedSet(array: [reiko, cupid, jasmine])
        cupidCombo.transitions = NSOrderedSet(array: [inProgressTransition, cupidtoJasmine])
        cupidCombo.last_trained = formatter.date(from: "7/21/2023")
        
        
        try? self.managedObjectContext.save()
    }
}

extension DataController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        _mapPoleMoves(controller.fetchedObjects as? [PoleMoveEntity])
        _mapTransitions(controller.fetchedObjects as? [TransitionEntity])
        _mapCombos(controller.fetchedObjects as? [ComboEntity])
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
    
    // MOVES
    
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
    
    func fetchPoleMoveById(_ id: UUID) -> PoleMoveEntity? {
        let predicate = NSPredicate(format: "id = %@", id as CVarArg)
        let result = fetchFirst(PoleMoveEntity.self, predicate: predicate)
        switch result {
        case .success(let moveEntity):
            if moveEntity != nil {
                return moveEntity
            } else {
                return nil
            }
        case .failure(_):
            print("Fetch failed")
            return nil
        }
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
    
    // TRANSITIONS
    
    func fetchTransitions(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) {
        if let predicate = predicate {
            transitionsController.fetchRequest.predicate = predicate
        }
        if let sortDescriptors = sortDescriptors {
            transitionsController.fetchRequest.sortDescriptors = sortDescriptors
        }
        try? transitionsController.performFetch()
        _mapTransitions(transitionsController.fetchedObjects)
    }
    
    func resetMoveTransitionFetch() {
        transitionsController.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "added_on", ascending: false)]
        transitionsController.fetchRequest.predicate = nil
        try? transitionsController.performFetch()
        _mapTransitions(transitionsController.fetchedObjects)
    }
    
    func updateTransition(transition: PoleTransition) {
        let predicate = NSPredicate(format: "id = %@", transition.id as CVarArg)
        let result = fetchFirst(TransitionEntity.self, predicate: predicate)
        let transitionEntity: TransitionEntity
        switch result {
        case .success(let managedObject):
            if managedObject != nil {
                transitionEntity = managedObject!
            } else {
                transitionEntity = TransitionEntity(context: managedObjectContext)
            }
            
            transitionEntity.id = transition.id
            let fromMove = fetchPoleMoveById(transition.from.id)
            let toMove = fetchPoleMoveById(transition.to.id)
            
            if fromMove != nil && toMove != nil {
                transitionEntity.from = fromMove!
                transitionEntity.to = toMove!
            } else {
                print("Pole moves not found")
                return
            }
            transitionEntity.status = transition.status
            transitionEntity.last_trained = transition.lastTrained
            
        case .failure(_):
            print("Couldn't fetch TransitionEntity to save")
        }
        
        saveData()
        
    }
    
    func deletePoleTransition(transition: PoleTransition) {
        let predicate = NSPredicate(format: "id = %@", transition.id as CVarArg)
            let result = fetchFirst(TransitionEntity.self, predicate: predicate)
            switch result {
            case .success(let managedObject):
                if let transitionEntity = managedObject {
                    managedObjectContext.delete(transitionEntity)
                }
            case .failure(_):
                print("Couldn't fetch TransitionEntity to save")
            }
            saveData()
    }
    
    // COMBOS
    
    func fetchCombos(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) {
        if let predicate = predicate {
            combosController.fetchRequest.predicate = predicate
        }
        if let sortDescriptors = sortDescriptors {
            combosController.fetchRequest.sortDescriptors = sortDescriptors
        }
        try? combosController.performFetch()
        _mapCombos(combosController.fetchedObjects)
    }
    
    func resetComboFetch() {
        combosController.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "added_on", ascending: false)]
        combosController.fetchRequest.predicate = nil
        try? combosController.performFetch()
        _mapCombos(combosController.fetchedObjects)
    }
    
    /** Utility function that maps fetched PoleMove structs to PoleMoveEntity objects */
    private func _mapPoleMoves(_ newMoves: [PoleMoveEntity]?) {
        if let newMoves = newMoves {
            self.movesStore = OrderedDictionary(uniqueKeysWithValues: newMoves.map({ ($0.id, PoleMove(move: $0)) }) )
        }
    }
    
    private func _mapTransitions(_ newTransitions: [TransitionEntity]?) {
        if let newTransitions = newTransitions {
            self.transitionsStore = OrderedDictionary(uniqueKeysWithValues: newTransitions.map({ ($0.id, PoleTransition(transition: $0))}))
        }
    }
    
    private func _mapCombos(_ newCombos: [ComboEntity]?) {
        if let newCombos = newCombos {
            self.combosStore = OrderedDictionary(uniqueKeysWithValues: newCombos.map({ ($0.id, PoleCombo(comboEntity: $0)) }))
        }
    }
}
