//
//  Item.swift
//  Pole Progress
//
//  Created by hafernan on 11/27/23.
//

import Foundation
import SwiftData

@Model
final class Move {
    // let uuid: UUID = UUID()
    // ^ this should work, but doesn't as of XCode 15
    let uuid: UUID
    var names: [String]
    var is_spin_only: Bool
    var status: Status
    var notes: String
    var last_trained: Date?
    
    init(
        names: [String],
        is_spin_only: Bool,
        status: Status,
        notes: String = "",
        last_trained: Date? = nil
    ) {
        self.uuid = UUID()
        self.names = names
        self.is_spin_only = is_spin_only
        self.status = status
        self.notes = notes
        self.last_trained = last_trained
    }
}
