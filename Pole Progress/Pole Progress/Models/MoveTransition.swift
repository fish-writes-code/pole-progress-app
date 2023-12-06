//
//  Transition.swift
//  Pole Progress
//
//  Created by hafernan on 12/5/23.
//

import Foundation
import OrderedCollections

struct MoveTransition: Identifiable, Hashable {
    let id: UUID
    let from: PoleMove
    let to: PoleMove
    var lastTrained: Date?
    let addedOn: Date
    
    init() {
        self.id = UUID()
        self.from = PoleMove()
        self.to = PoleMove()
        self.addedOn = Date()
    }
    
    init(from: PoleMove, to: PoleMove, lastTrained: Date?) {
        self.id = UUID()
        self.from = from
        self.to = to
        self.lastTrained = lastTrained
        self.addedOn = Date()
    }
    
    init(transition: TransitionEntity) {
        self.id = transition.id
        self.from = PoleMove(move: transition.from)
        self.to = PoleMove(move: transition.to)
        self.lastTrained = transition.last_trained
        self.addedOn = transition.added_on
    }
    
    var lastTrainedString: String {
        return self.lastTrained != nil ? lastTrained!.dateOnlyFormat : "Never"
    }
}

struct PoleCombo: Identifiable, Hashable {
    let id: UUID
    var name: String
    var movesInCombo: OrderedSet<PoleMove>
}
