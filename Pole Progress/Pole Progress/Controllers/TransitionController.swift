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
}
