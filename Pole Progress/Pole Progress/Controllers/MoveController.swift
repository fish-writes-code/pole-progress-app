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
    @Published var moveToEdit: PoleMove
    @Published private var dataController: DataController
    
    var anyCancellable: AnyCancellable? = nil
    
    init(move: PoleMove?, dataController: DataController = DataController.shared) {
        if let move = move {
            self.moveToEdit = move
        } else {
            self.moveToEdit = PoleMove()
        }
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
    
    func addOrUpdatePoleMove() {
        dataController.updatePoleMove(moveStruct: moveToEdit)
    }
}
