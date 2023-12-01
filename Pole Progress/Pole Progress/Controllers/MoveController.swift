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
    var moves: [PoleMove] { dataController.moves }
    
    init(dataController: DataController) {
        self.dataController = dataController
        anyCancellable = dataController.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }
}
