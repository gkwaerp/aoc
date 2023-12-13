//
//  Solver_2023_13.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 13/12/2023.
//

import Foundation

final class Solver_2023_13: Solver {

    private var grids: [StringGrid] = []

    override func didLoadFunction() {
        grids = defaultInputFileString
            .loadAsStringArray(separator: "\n\n")
            .map { $0.components(separatedBy: .newlines) }
            .map { StringGrid(stringArray: $0) }
    }

    override func solveFunction1() -> CustomStringConvertible {
        getSummaryCount(for: grids)
    }

    override func solveFunction2() -> CustomStringConvertible {
        getSummaryCountWithSmudgeFix(for: grids)
    }

    private func getSummaryCount(for grids: [StringGrid]) -> Int {
        var left = 0
        var above = 0

        grids.forEach { grid in
            guard let reflectionResult = getReflectionResult(for: grid, avoiding: nil) else { fatalError("No reflection found for grid!") }
            left += reflectionResult.left
            above += reflectionResult.above
        }

        return left + 100 * above
    }

    struct ReflectionResult: Equatable {
        let left: Int
        let above: Int

        static func ==(lhs: ReflectionResult, rhs: ReflectionResult) -> Bool {
            lhs.left == rhs.left &&
            lhs.above == rhs.above
        }
    }

    private func getReflectionResult(for grid: StringGrid, avoiding: ReflectionResult?) -> ReflectionResult? {
        for x in 0..<grid.width {
            var leftMost = x
            var rightMost = x + 1
            if grid.columnString(for: leftMost) == grid.columnString(for: rightMost) {
                let center = rightMost
                var shouldAdd = true
                while leftMost >= 0 && rightMost < grid.width && shouldAdd {
                    shouldAdd = grid.columnString(for: leftMost) == grid.columnString(for: rightMost)
                    leftMost -= 1
                    rightMost += 1
                }

                let reflectionResult = ReflectionResult(left: center, above: 0)
                if shouldAdd && reflectionResult != avoiding {
                    return reflectionResult
                }
            }
        }

        for y in 0..<grid.height {
            var topMost = y
            var bottomMost = y + 1
            if grid.rowString(for: topMost) == grid.rowString(for: bottomMost) {
                let center = bottomMost
                var shouldAdd = true
                while topMost >= 0 && bottomMost < grid.height && shouldAdd {
                    shouldAdd = grid.rowString(for: topMost) == grid.rowString(for: bottomMost)
                    topMost -= 1
                    bottomMost += 1
                }

                let reflectionResult = ReflectionResult(left: 0, above: center)
                if shouldAdd && reflectionResult != avoiding {
                    return reflectionResult
                }
            }
        }

        return nil
    }

    private func getSummaryCountWithSmudgeFix(for grids: [StringGrid]) -> Int {
        var left = 0
        var above = 0

        grids.forEach { grid in
            guard let originalReflectionResult = getReflectionResult(for: grid, avoiding: nil) else { fatalError("No reflection result for grid!") }

            for gridPoint in grid.gridPoints {
                let originalValue = grid.getValue(at: gridPoint)!
                let newValue = originalValue == "." ? "#" : "."
                grid.setValue(at: gridPoint, to: newValue)
                if let reflectionResult = getReflectionResult(for: grid, avoiding: originalReflectionResult) {
                    left += reflectionResult.left
                    above += reflectionResult.above
                    return
                }
                grid.setValue(at: gridPoint, to: originalValue)
            }

            fatalError("No reflection result after smudge fix!")
        }

        return left + 100 * above
    }
}

extension Solver_2023_13: TestableDay {
    func runTests() {
        let input = """
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
"""
            .components(separatedBy: "\n\n")

        let grids = input
            .map { $0.components(separatedBy: .newlines) }
            .map { StringGrid(stringArray: $0) }

        let result1 = getSummaryCount(for: grids)
        let expected1 = 405
        assert(result1 == expected1)

        let result2 = getSummaryCountWithSmudgeFix(for: grids)
        let expected2 = 400
        assert(result2 == expected2)
    }
}

fileprivate extension StringGrid {
    func rowString(for row: Int) -> String? {
        guard row < height else { return nil }
        return (0..<width).map { getValue(at: IntPoint(x: $0, y: row))! }.reduce("", +)
    }

    func columnString(for column: Int) -> String? {
        guard column < width else { return nil }
        return (0..<height).map { getValue(at: IntPoint(x: column, y: $0))! }.reduce("", +)
    }
}
