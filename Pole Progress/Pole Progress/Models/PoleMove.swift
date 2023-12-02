//
//  PoleMoveModel.swift
//  Pole Progress
//
//  Created by hafernan on 11/30/23.
//

import Foundation

/** Struct representation of a PoleMoveEntity  */
struct PoleMove: Identifiable, Hashable {
    let id: UUID
    let primaryName: String
    var otherNames: String
    var status: Status
    var isSpinOnly: Bool
    var lastTrained: Date?
    var notes: String
    let addedOn: Date
    
    init() {
        self.id = UUID()
        self.primaryName = ""
        self.otherNames = ""
        self.status = .toTry
        self.isSpinOnly = false
        self.lastTrained = nil
        self.notes = ""
        self.addedOn = Date()
        
    }
    
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
    
    /** the last trained date or "Never" */
    var lastTrainedString: String {
        return self.lastTrained != nil ? lastTrained!.dateOnlyFormat : "Never"
    }
    
    /** sn array of strings containing all this PoleMove's names (primary and other) */
    var allNamesArray: [String] {
        var allNames: [String] = [self.primaryName]
        allNames.insert(contentsOf: self.otherNames.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines )}, at: 1)
        return allNames
    }
}
