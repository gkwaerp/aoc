//
//  Solver_2023_18.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 18/12/2023.
//

import Foundation

final class Solver_2023_18: Solver {

    private var input: [String] = []

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsStringArray()
    }

    override func solveFunction1() -> CustomStringConvertible {
        getCubicMeters(for: input, flipped: false)
    }

    override func solveFunction2() -> CustomStringConvertible {
        getCubicMeters(for: input, flipped: true)
    }

    private func getMovementOffset(for string: String, flipped: Bool) -> IntPoint {
        let split = string.components(separatedBy: " ")
        let direction = Direction(string: split[0])!
        let steps = split[1].intValue!
        let color = split[2]
            .replacingOccurrences(of: "(#", with: "")
            .replacingOccurrences(of: ")", with: "")
            .convertToStringArray()

        let actualSteps: Int
        let actualDirection: Direction
        if flipped {
            actualSteps = Int(color[...4].joined(), radix: 16)!
            switch color[5] {
            case "0": actualDirection = .east
            case "1": actualDirection = .south
            case "2": actualDirection = .west
            case "3": actualDirection = .north
            default: fatalError("Invalid direction")
            }
        } else {
            actualSteps = steps
            actualDirection = direction
        }
        return actualDirection.movementVector.scaled(by: actualSteps)
    }

    private func getCubicMeters(for input: [String], flipped: Bool) -> Int {
        var positions: [IntPoint] = [.origin]
        var boundaryLength = 0

        var currPos = IntPoint.origin
        input.forEach { string in
            let movementOffset = getMovementOffset(for: string, flipped: flipped)
            currPos += movementOffset
            boundaryLength += movementOffset.magnitude()
            positions.append(currPos)
        }

        var area = 0
        for i in 1..<positions.count - 1 {
            area += positions[i].x * (positions[i + 1].y - positions[i - 1].y)
        }

        return (boundaryLength + area) / 2 + 1
    }
}

extension Solver_2023_18: TestableDay {
    func runTests() {
        let input = """
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
"""
            .components(separatedBy: .newlines)

        let result1 = getCubicMeters(for: input, flipped: false)
        let expected1 = 62
        assert(result1 == expected1)

        let result2 = getCubicMeters(for: input, flipped: true)
        let expected2 = 952408144115
        assert(result2 == expected2)
    }
}
