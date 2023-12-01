//
//  PoleMove+CoreDataProperties.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//
//

import Foundation
import CoreData


extension PoleMoveEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PoleMoveEntity> {
        return NSFetchRequest<PoleMoveEntity>(entityName: "PoleMoveEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var added_on: Date
    @NSManaged public var is_spin_only: Bool
    @NSManaged public var last_trained: Date?
    @NSManaged public var notes: String
    @NSManaged public var other_names: String
    @NSManaged public var primary_name: String
    @NSManaged public var status: Status

}

extension PoleMoveEntity : Identifiable {
    override public func awakeFromInsert() {
            setPrimitiveValue(NSDate(), forKey: "added_on")
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
        return last_trained != nil ? last_trained!.dateOnlyFormat : "Never"
    }
}

