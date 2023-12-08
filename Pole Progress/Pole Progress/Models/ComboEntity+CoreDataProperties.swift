//
//  ComboEntity+CoreDataProperties.swift
//  Pole Progress
//
//  Created by hafernan on 12/7/23.
//
//

import Foundation
import CoreData


extension ComboEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ComboEntity> {
        return NSFetchRequest<ComboEntity>(entityName: "ComboEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var moves: NSOrderedSet
    @NSManaged public var transitions: NSOrderedSet
    @NSManaged public var status: Status
    @NSManaged public var last_trained: Date?
    @NSManaged public var added_on: Date

}

extension ComboEntity : Identifiable {
    override public func awakeFromInsert() {
        setPrimitiveValue(NSDate(), forKey: "added_on")
    }
}
