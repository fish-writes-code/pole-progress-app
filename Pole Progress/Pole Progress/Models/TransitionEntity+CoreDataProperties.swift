//
//  TransitionEntity+CoreDataProperties.swift
//  Pole Progress
//
//  Created by hafernan on 12/5/23.
//
//

import Foundation
import CoreData


extension TransitionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransitionEntity> {
        return NSFetchRequest<TransitionEntity>(entityName: "TransitionEntity")
    }

    
    @NSManaged public var id: UUID
    @NSManaged public var added_on: Date
    @NSManaged public var last_trained: Date?
    @NSManaged public var status: Status
    @NSManaged public var from: PoleMoveEntity
    @NSManaged public var to: PoleMoveEntity

}

extension TransitionEntity : Identifiable {
    override public func awakeFromInsert() {
        setPrimitiveValue(NSDate(), forKey: "added_on")
    }
}
