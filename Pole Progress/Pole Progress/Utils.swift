//
//  Utils.swift
//  Pole Progress
//
//  Created by hafernan on 11/29/23.
//

import Foundation

extension Date {
    var dateOnlyFormat: String {
        return self.formatted(date: .abbreviated, time: .omitted)
    }
}
