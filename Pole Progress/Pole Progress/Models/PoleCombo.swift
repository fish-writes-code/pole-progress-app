//
//  PoleCombo.swift
//  Pole Progress
//
//  Created by hafernan on 12/7/23.
//

import Foundation
import OrderedCollections

struct PoleCombo: Identifiable, Hashable {
    let id: UUID
    var name: String
    var moves: OrderedSet<PoleMove>
    var transitions: OrderedSet<PoleTransition>
    var status: Status
    var lastTrained: Date?
    let addedOn: Date
    
    init() {
        self.id = UUID()
        self.name = ""
        self.moves = OrderedSet()
        self.transitions = OrderedSet()
        self.status = Status.toTry
        self.addedOn = Date()
    }
    
    init(comboEntity: ComboEntity) {
        self.id = comboEntity.id
        self.name = comboEntity.name
        self.moves = OrderedSet<PoleMove>(comboEntity.moves.array.map({ PoleMove(move: $0 as! PoleMoveEntity) }))
        self.transitions = OrderedSet<PoleTransition>(comboEntity.transitions.array.map({ PoleTransition(transition: $0 as! TransitionEntity) }))
        self.status = comboEntity.status
        self.lastTrained = comboEntity.last_trained
        self.addedOn = comboEntity.added_on
    }
    
    init(name: String, moves: [PoleMove], transitions: [PoleTransition], status: Status, lastTrained: Date?) {
        self.id = UUID()
        self.name = name
        self.moves = OrderedSet<PoleMove>(moves)
        self.transitions = OrderedSet<PoleTransition>(transitions)
        self.status = status
        self.lastTrained = lastTrained
        self.addedOn = Date()
    }
    
    var lastTrainedString: String {
        return self.lastTrained != nil ? lastTrained!.dateOnlyFormat : "Never"
    }
    
    var moveNames: [String] {
        return self.moves.map { $0.primaryName }
    }
}
