//
//  StatusEnum.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//

import Foundation

@objc public enum Status: Int16, CaseIterable, Identifiable {
    public var id: Self { self }
    
    case toTry = 0
    case inProgress = 1
    case solid = 2
    case blocked = 3
    
    var description: String {
        switch self {
        case .toTry: return "To Try"
        case .inProgress: return "In Progress"
        case .solid: return "Solid"
        case .blocked: return "Blocked"
        }
    }
}
