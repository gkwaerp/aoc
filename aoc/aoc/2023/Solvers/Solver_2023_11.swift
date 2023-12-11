//
//  Solver_2023_11.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 11/12/2023.
//

import Foundation

final class Solver_2023_11: Solver {
    private var input: [String] = []

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsStringArray()
    }

    override func solveFunction1() -> CustomStringConvertible {
        Observatory(input, expansionFactor: 2).findSumOfClosest()
    }

    override func solveFunction2() -> CustomStringConvertible {
        Observatory(input, expansionFactor: 1_000_000).findSumOfClosest()
    }
}

extension Solver_2023_11: TestableDay {
    func runTests() {
        let input = """
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
"""
            .components(separatedBy: .newlines)

        let observatory1 = Observatory(input, expansionFactor: 2)
        let result1 = observatory1.findSumOfClosest()
        let expected1 = 374
        assert(result1 == expected1)

        let observatory2 = Observatory(input, expansionFactor: 10)
        let result2 = observatory2.findSumOfClosest()
        let expected2 = 1030
        assert(result2 == expected2)

        let observatory3 = Observatory(input, expansionFactor: 100)
        let result3 = observatory3.findSumOfClosest()
        let expected3 = 8410
        assert(result3 == expected3)
    }
}

extension Solver_2023_11 {
    final class Observatory {
        var starMap: [IntPoint: IntPoint]

        init(_ strings: [String], expansionFactor: Int) {
            let arrayed = strings.map { $0.convertToStringArray() }
            var columnsToExpand: [Int] = []
            var rowsToExpand: [Int] = []

            for x in 0..<arrayed[0].count {
                if !(0..<arrayed.count).contains(where: { arrayed[$0][x] == "#" }) {
                    columnsToExpand.append(x)
                }
            }

            for y in 0..<strings.count {
                if !strings[y].contains(where: { $0 == "#" }) {
                    rowsToExpand.append(y)
                }
            }

            starMap = [:]

            for originalPosition in StringGrid(stringArray: strings).positions(matching: { $0 != "." }) {
                let currentPosition = originalPosition.copy()

                for column in columnsToExpand {
                    if originalPosition.x > column {
                        currentPosition.x += expansionFactor - 1
                    }
                }

                for row in rowsToExpand {
                    if originalPosition.y > row {
                        currentPosition.y += expansionFactor - 1
                    }
                }

                starMap[originalPosition] = currentPosition
            }
        }

        func findSumOfClosest() -> Int {
            let positions = Array(starMap.values)
            var sum = 0

            for a in 0..<positions.count - 1 {
                for b in a + 1..<positions.count {
                    let p1 = positions[a]
                    let p2 = positions[b]
                    sum += p1.manhattanDistance(to: p2)
                }
            }

            return sum
        }
    }
}
