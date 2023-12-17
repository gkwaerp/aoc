//
//  Solver_2023_16.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 16/12/2023.
//

import Foundation

final class Solver_2023_16: Solver {
    class Beam {
        var direction: Direction
        var position: IntPoint

        init(direction: Direction, position: IntPoint) {
            self.direction = direction
            self.position = position
        }

        var hashValue: String {
            "\(direction)-\(position)"
        }
    }

    private var input: [String] = []

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsStringArray()
    }

    override func solveFunction1() -> CustomStringConvertible {
        countEnergizedTiles(in: StringGrid(stringArray: input))
    }

    override func solveFunction2() -> CustomStringConvertible {
        getHighestEnergizedTileCount(in: StringGrid(stringArray: input))
    }

    private func countEnergizedTiles(in grid: StringGrid, initialBeam: Beam = Beam(direction: .east, position: .origin)) -> Int {
        var beams: [Beam] = [initialBeam]
        var energizedTiles: Set<IntPoint> = []

        var visited: Set<String> = [initialBeam.hashValue]

        while let beam = beams.popLast() {
            while true {
                guard grid.isWithinBounds(beam.position) else { break }
                energizedTiles.insert(beam.position)
                let value = grid.getValue(at: beam.position)!
                if value == "|" {
                    if beam.direction == .east || beam.direction == .west {
                        beams.append(Beam(direction: .north, position: beam.position + Direction.north.movementVector))
                        beams.append(Beam(direction: .south, position: beam.position + Direction.south.movementVector))
                        break
                    }
                } else if value == "-" {
                    if beam.direction == .north || beam.direction == .south {
                        beams.append(Beam(direction: .east, position: beam.position + Direction.east.movementVector))
                        beams.append(Beam(direction: .west, position: beam.position + Direction.west.movementVector))
                        break
                    }
                } else if value == "/" {
                    if beam.direction == .east { beam.direction = .north }
                    else if beam.direction == .south { beam.direction = .west }
                    else if beam.direction == .west { beam.direction = .south }
                    else if beam.direction == .north { beam.direction = .east }
                } else if value == #"\"# {
                    if beam.direction == .east { beam.direction = .south }
                    else if beam.direction == .south { beam.direction = .east }
                    else if beam.direction == .west { beam.direction = .north }
                    else if beam.direction == .north { beam.direction = .west }
                }
                beam.position += beam.direction.movementVector
                let insertion = visited.insert(beam.hashValue)
                guard insertion.inserted else { break }
            }
        }

        return energizedTiles.count
    }

    func getHighestEnergizedTileCount(in grid: StringGrid) -> Int {
        var energizedCounts: [Int] = []

        for x in 0..<grid.width {
            energizedCounts.append(countEnergizedTiles(in: grid, initialBeam: Beam(direction: .south, position: IntPoint(x: x, y: 0))))
            energizedCounts.append(countEnergizedTiles(in: grid, initialBeam: Beam(direction: .north, position: IntPoint(x: x, y: grid.height - 1))))
        }

        for y in 0..<grid.height {
            energizedCounts.append(countEnergizedTiles(in: grid, initialBeam: Beam(direction: .east, position: IntPoint(x: 0, y: y))))
            energizedCounts.append(countEnergizedTiles(in: grid, initialBeam: Beam(direction: .west, position: IntPoint(x: grid.width - 1, y: y))))
        }

        return energizedCounts.max()!
    }
}

extension Solver_2023_16: TestableDay {
    func runTests() {
        let input = #"""
.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....
"""#
            .components(separatedBy: .newlines)

        let grid = StringGrid(stringArray: input)
        let result1 = countEnergizedTiles(in: grid)
        let expected1 = 46
        assert(result1 == expected1)

        let result2 = getHighestEnergizedTileCount(in: grid)
        let expected2 = 51
        assert(result2 == expected2)
    }
}
