//
//  CalendarView.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 29/11/2022.
//

import SwiftUI

struct CalendarView: View {
    let year: Int

    @State private var path: [Int] = []

    private let numColumns = 6
    private let numRows = 4

    /// Day --> Solver
    private typealias SolverDictionary = [Int: Solver.Type]
    @State private var solvers: SolverDictionary = [:]

    var body: some View {
        NavigationStack(path: $path) {
            grid
            .navigationDestination(for: Int.self) { day in
                let solver = solvers[day]!.init(day: day)
                DayView(solver: solver)
            }
            .navigationTitle("Advent of Code, \(String(year))")
        }
        .onAppear {
            updateDays()
        }
    }

    private var grid: some View {
        return Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 8) {
            ForEach(0..<numColumns, id: \.self) { column in
                GridRow(alignment: .center) {
                    ForEach(0..<numRows, id: \.self) { row in
                        let day = column * numRows + row + 1
                        button(for: day)
                    }
                }
            }

            GridRow {
                button(for: 25)
                    .gridCellColumns(4)
            }
        }
    }

    private func updateDays() {
        guard solvers.isEmpty else {
            return
        }

        guard let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
            fatalError("No bundle name found!")
        }

        let sanitizedBundleName = appName.replacingOccurrences(of: " ", with: "_")
        for i in 1...25 {
            let solverClassName = String(format: "Solver_%04d_%02d", year, i)
            let finalSolverName = "\(sanitizedBundleName).\(solverClassName)"
            guard let solverType = NSClassFromString(finalSolverName) as? Solver.Type else { continue }
            solvers[i] = solverType
        }
    }

    private func button(for day: Int) -> some View {
        let isDisabled = solvers[day] == nil

        return NavigationLink(value: day, label: {
            Text("Day \(day.toDayString())")
                .padding()
                .background(isDisabled ? Color.gray : Color.green)
                .cornerRadius(8)
        }).disabled(isDisabled)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(year: 2022)
    }
}

