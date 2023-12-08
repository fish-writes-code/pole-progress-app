//
//  ComboController.swift
//  Pole Progress
//
//  Created by hafernan on 12/7/23.
//

import Foundation
import CoreData
import Combine

@MainActor
final class ComboController: ObservableObject {
    @Published private var dataController: DataController
    
    var anyCancellable: AnyCancellable? = nil
    
    init(dataController: DataController = DataController.shared) {
        self.dataController = dataController
        anyCancellable = dataController.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }
    
    var combos: [PoleCombo] { dataController.combos }
    
    func fetchCombos() {
        self.dataController.fetchCombos()
    }
}
