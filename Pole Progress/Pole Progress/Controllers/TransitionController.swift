//
//  TransitionController.swift
//  Pole Progress
//
//  Created by hafernan on 12/5/23.
//

import Foundation
import CoreData
import Combine

@MainActor
final class TransitionController: ObservableObject {
    @Published private var dataController: DataController
    
    var anyCancellable: AnyCancellable? = nil
    
    init(dataController: DataController = DataController.shared) {
        self.dataController = dataController
        anyCancellable = dataController.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }
    
    /** Array of MoveTransition  structs */
    var transitions: [PoleTransition] { dataController.transitions }
    
    func fetchTransitions() {
        self.dataController.fetchTransitions()
    }
    
    func getTransitionsWithStartingMove(startingMove: PoleMove) -> [PoleTransition] {
        let result = transitions.filter { $0.from == startingMove }
        return result
    }
    
    func getTransitionsWithEndingMove(endingMove: PoleMove) -> [PoleTransition] {
        let result = transitions.filter { $0.to == endingMove }
        return result
    }
    
    func getTransitionsByName(name: String) -> [PoleTransition] {
        let result = transitions.filter { $0.name == name }
        return result
    }
    
    func addOrUpdateTransition(transition: PoleTransition) {
        dataController.updateTransition(transition: transition)
    }
}
