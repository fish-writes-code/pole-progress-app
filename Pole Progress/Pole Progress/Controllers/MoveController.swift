//
//  MoveController.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//

import Foundation
import CoreData
import Combine

@MainActor
final class MoveController: ObservableObject {
    @Published private var dataController: DataController
    
    var anyCancellable: AnyCancellable? = nil
    
    init(dataController: DataController = DataController.shared) {
        self.dataController = dataController
        anyCancellable = dataController.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }
    
    /** Array of PoleMove structs */
    var moves: [PoleMove] { dataController.moves }
    
    func fetchPoleMoves() {
        self.dataController.fetchPoleMoves()
    }
    
    func addOrUpdatePoleMove(move: PoleMove) {
        dataController.updatePoleMove(moveStruct: move)
    }
    
    func deletePoleMove(_ moveToDelete: PoleMove) {
        dataController.deletePoleMove(move: moveToDelete)
    }
}
