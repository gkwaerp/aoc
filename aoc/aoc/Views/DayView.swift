//
//  DayView.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 29/11/2022.
//

import Foundation
import SwiftUI

struct DayView: View {
    let solver: Solver

    var body: some View {
        Text(solver.text)
            .navigationTitle(solver.navigationTitle)
    }
}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView(solver: DayView.MockSolver(day: 15))
    }
}


private extension DayView {
    class MockSolver: Solver {
    }
}
