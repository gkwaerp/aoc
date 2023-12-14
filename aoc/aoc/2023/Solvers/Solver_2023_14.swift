//
//  Solver_2023_14.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 14/12/2023.
//

import Foundation

final class Solver_2023_14: Solver {
    private var input: [String] = []

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsStringArray()
    }

    override func solveFunction1() -> CustomStringConvertible {
        let grid = StringGrid(stringArray: input)
        tilt(grid: grid, in: .north)
        return getTotalSupportLoad(grid)
    }

    override func solveFunction2() -> CustomStringConvertible {
        let grid = StringGrid(stringArray: input)
        doSpinCycles(grid, numTimes: 1_000_000_000)
        return getTotalSupportLoad(grid)
    }

    private func tilt(grid: StringGrid, in direction: Direction) {
        var done = false
        let movementVector = direction.movementVector

        while !done {
            done = true
            let rollingRockPositions = Set(grid.positions(matching: { $0 == "O" }))
            for rockPos in rollingRockPositions {
                let newPos = rockPos + movementVector
                guard grid.getValue(at: newPos) == "." else { continue }
                grid.setValue(at: newPos, to: "O")
                grid.setValue(at: rockPos, to: ".")
                done = false
            }
        }
    }

    private func getTotalSupportLoad(_ grid: StringGrid) -> Int {
        grid.positions(matching: { $0 == "O" })
            .map { grid.height - $0.y }
            .reduce(0, +)
    }

    private func doSpinCycles(_ grid: StringGrid, numTimes: Int) {
        let directions: [Direction] = [.north, .west, .south, .east]

        var history: [String: Int] = [:]
        var loopStart = -1
        var loopLength = -1

        var numSpinCyclesPerformed = 0
        while numSpinCyclesPerformed < numTimes {
            numSpinCyclesPerformed += 1
            directions.forEach { tilt(grid: grid, in: $0) }
            let historyKey = grid.asText(printClosure: StringGrid.defaultPrintClosure())
            history[historyKey, default: 0] += 1

            if loopStart < 0 && history[historyKey] == 2 {
                loopStart = numSpinCyclesPerformed
            } else if loopLength < 0 && history[historyKey] == 3 {
                loopLength = numSpinCyclesPerformed - loopStart
                break
            }
        }

        let remaining = (numTimes - numSpinCyclesPerformed) % loopLength
        if remaining > 0 {
            for _ in 0..<remaining { directions.forEach { tilt(grid: grid, in: $0) } }
        }
    }
}

extension Solver_2023_14: TestableDay {
    func runTests() {
        let input = """
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
"""
            .components(separatedBy: .newlines)
        let grid1 = StringGrid(stringArray: input)
        tilt(grid: grid1, in: .north)
        let result1 = getTotalSupportLoad(grid1)
        let expected1 = 136
        assert(result1 == expected1)

        let grid2 = StringGrid(stringArray: input)
        doSpinCycles(grid2, numTimes: 1_000_000_000)
        let result2 = getTotalSupportLoad(grid2)
        let expected2 = 64
        assert(result2 == expected2)
    }
}
