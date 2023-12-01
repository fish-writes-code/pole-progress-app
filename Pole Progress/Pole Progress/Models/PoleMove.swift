//
//  PoleMoveModel.swift
//  Pole Progress
//
//  Created by hafernan on 11/30/23.
//

import Foundation

struct PoleMove {
    let id: UUID
    let primaryName: String
    var otherNames: String
    var status: Status
    var isSpinOnly: Bool
    var lastTrained: Date?
    var notes: String
    var addedOn: Date
    
    init(move: PoleMoveEntity) {
        self.id = move.id
        self.primaryName = move.primary_name
        self.otherNames = move.other_names
        self.status = move.status
        self.isSpinOnly = move.is_spin_only
        self.lastTrained = move.last_trained
        self.notes = move.notes
        self.addedOn = move.added_on
    }
    
    init(primaryName: String, otherNames: String, status: Status, isSpinOnly: Bool, lastTrained: Date?, notes: String) {
        self.id = UUID()
        self.primaryName = primaryName
        self.otherNames = otherNames
        self.status = status
        self.isSpinOnly = isSpinOnly
        self.lastTrained = lastTrained
        self.notes = notes
        self.addedOn = Date()
    }
    
    func getStatusString() -> String {
        switch status {
        case .toTry: return "To Try"
        case .inProgress: return "In Progress"
        case .solid: return "Solid"
        case .blocked: return "Blocked"
        }
    }
    
    func getLastTrainedString() -> String {
        return self.lastTrained != nil ? lastTrained!.dateOnlyFormat : "Never"
    }
    
    func getAllMovesArray() -> [String] {
        var allMoves: [String] = [self.primaryName]
        allMoves.insert(contentsOf: self.otherNames.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines )}, at: 1)
        return allMoves
    }
}
