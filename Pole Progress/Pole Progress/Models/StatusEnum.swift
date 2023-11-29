//
//  StatusEnum.swift
//  Pole Progress
//
//  Created by hafernan on 11/28/23.
//

import Foundation

@objc public enum Status: Int16 {
    case toTry = 0
    case inProgress = 1
    case solid = 2
    case blocked = 3
}
