//
//  aocApp.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 29/11/2022.
//

import SwiftUI

@main
struct aocApp: App {
    var body: some Scene {
        let currentYear = Calendar.current.dateComponents([.year], from: .now).year!
        let years = (2015...currentYear).filter { yearContainsAnySolutions($0)}
        WindowGroup {
            YearView(years: years)
        }
    }

    private func yearContainsAnySolutions(_ year: Int) -> Bool {
        (1...25).contains(where: { Solver.getType(year: year, day: $0) != nil })
    }
}
