//
//  Transition.swift
//  Pole Progress
//
//  Created by hafernan on 12/5/23.
//

import Foundation
import OrderedCollections

struct PoleTransition: Identifiable, Hashable {
    let id: UUID
    var name: String
    var from: PoleMove
    var to: PoleMove
    var status: Status
    var lastTrained: Date?
    let addedOn: Date
    
    init() {
        self.id = UUID()
        self.name = ""
        self.from = PoleMove()
        self.to = PoleMove()
        self.status = Status.toTry
        self.addedOn = Date()
    }
    
    init(name: String?, from: PoleMove, to: PoleMove, status: Status?, lastTrained: Date?) {
        self.id = UUID()
        self.name = name ?? ""
        self.from = from
        self.to = to
        self.status = status ?? Status.toTry
        self.lastTrained = lastTrained
        self.addedOn = Date()
    }
    
    init(transition: TransitionEntity) {
        self.id = transition.id
        self.name = transition.name
        self.from = PoleMove(move: transition.from)
        self.to = PoleMove(move: transition.to)
        self.status = transition.status
        self.lastTrained = transition.last_trained
        self.addedOn = transition.added_on
    }
    
    var lastTrainedString: String {
        return self.lastTrained != nil ? lastTrained!.dateOnlyFormat : "Never"
    }
}
