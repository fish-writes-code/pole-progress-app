//
//  PoleMoveModel.swift
//  Pole Progress
//
//  Created by hafernan on 11/30/23.
//

import Foundation

/** Struct representation of a PoleMoveEntity  */
struct PoleMove: Identifiable {
    let id: UUID
    let primaryName: String
    var otherNames: String
    var status: Status
    var isSpinOnly: Bool
    var lastTrained: Date?
    var notes: String
    var addedOn: Date
    
    /** initializes a PoleMove struct from a PoleMoveEntity */
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
    
    /** initializes a PoleMove struct using its mutable fields */
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
    
    /** Returns the String label of the PoleMove Status enum*/
    func getStatusString() -> String {
        switch status {
        case .toTry: return "To Try"
        case .inProgress: return "In Progress"
        case .solid: return "Solid"
        case .blocked: return "Blocked"
        }
    }
    
    /** Returns the last trained date or "Never" */
    func getLastTrainedString() -> String {
        return self.lastTrained != nil ? lastTrained!.dateOnlyFormat : "Never"
    }
    
    /** Returns an array of strings containing all this PoleMove's names (primary and other) */
    func getAllNamesArray() -> [String] {
        var allNames: [String] = [self.primaryName]
        allNames.insert(contentsOf: self.otherNames.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines )}, at: 1)
        return allNames
    }
}
