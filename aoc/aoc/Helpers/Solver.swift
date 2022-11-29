//
//  Solver.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 29/11/2022.
//

import Foundation

class Solver {
    private let day: Int

    var navigationTitle: String {
        day.toDayString()
    }

    var text: String {
        return ""
    }

    required init(day: Int) {
        self.day = day
    }
}
