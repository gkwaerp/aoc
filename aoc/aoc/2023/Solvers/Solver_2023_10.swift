//
//  Solver_2023_10.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 10/12/2023.
//

import Foundation

final class Solver_2023_10: Solver {
    override func solveFunction1() -> CustomStringConvertible {
        getFarthestDistance(defaultInputFileString.loadAsStringGrid())
    }

    override func solveFunction2() -> CustomStringConvertible {
        var stringArray = defaultInputFileString.loadAsStringArray().map { ".\($0)." }
        let padding = Array(repeating: ".", count: stringArray[0].count).joined()
        stringArray.insert(padding, at: 0)
        stringArray.append(padding)
        let grid = StringGrid(stringArray: stringArray)
        return getEnclosedTileCount(grid, replaceStartWith: "-")
    }

    func getFarthestDistance(_ grid: StringGrid) -> Int {
        PipeMap(grid: grid).getFarthestDistance()
    }

    func getEnclosedTileCount(_ grid: StringGrid, replaceStartWith replacement: String) -> Int {
        PipeMap(grid: grid).getEnclosedTileCount(replaceStartWith: replacement)
    }
}

extension Solver_2023_10: TestableDay {
    func runTests() {
        let input1 = """
-L|F7
7S-7|
L|7||
-L-J|
L|-JF
"""
            .components(separatedBy: .newlines)
        let grid1 = StringGrid(stringArray: input1)
        let steps1 = getFarthestDistance(grid1)
        let expected1 = 4
        assert(steps1 == expected1)

        let input2 = """
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
"""
            .components(separatedBy: .newlines)
        let grid2 = StringGrid(stringArray: input2)
        let steps2 = getFarthestDistance(grid2)
        let expected2 = 8
        assert(steps2 == expected2)

        let input3 = """
......................
.FF7FSF7F7F7F7F7F---7.
.L|LJ||||||||||||F--J.
.FL-7LJLJ||||||LJL-77.
.F--JF--7||LJLJ7F7FJ-.
.L---JF-JLJ.||-FJLJJ7.
.|F|F-JF---7F7-L7L|7|.
.|FFJF7L7F-JF7|JL---7.
.7-L-JL7||F7|L7F-7F7|.
.L.L7LFJ|||||FJL7||LJ.
.L7JLJL-JLJLJL--JLJ.L.
"""
            .components(separatedBy: .newlines)
        let grid3 = StringGrid(stringArray: input3)
        let enclosedResult = getEnclosedTileCount(grid3, replaceStartWith: "F")
        let expected3 = 10
        assert(enclosedResult == expected3)

    }
}

extension Solver_2023_10 {
    final class PipeMap {
        let grid: StringGrid

        var loop: [IntPoint]

        init(grid: StringGrid) {
            self.grid = grid
            self.loop = []
        }

        private func getConnections(for value: String) -> [Direction] {
            switch value {
            case "|": return [.north, .south]
            case "-": return [.east, .west]
            case "L": return [.north, .east]
            case "J": return [.north, .west]
            case "7": return [.south, .west]
            case "F": return [.south, .east]
            case ".": return []
            case "S": return []
            default: fatalError("Invalid tile")
            }
        }

        private func getStartPosition() -> IntPoint {
            grid.firstPosition(matching: { $0 == "S" })!
        }

        private func findLoop() {
            let startPos = getStartPosition()
            self.loop = [startPos]

            var direction = Direction.allCases.first { direction in
                let candidatePos = startPos + direction.movementVector
                guard let candidateValue = grid.getValue(at: candidatePos) else { return false  }

                let connections = getConnections(for: candidateValue)
                return connections.contains(where: { $0 == direction.reverse })
            }!

            var currPos = startPos + direction.movementVector
            while currPos != startPos {
                loop.append(currPos)
                let connections = getConnections(for: grid.getValue(at: currPos)!)
                direction = connections.first(where: { $0 != direction.reverse })!
                currPos += direction.movementVector
            }
        }

        func getFarthestDistance() -> Int {
            findLoop()
            return loop.count / 2
        }

        func getEnclosedTileCount(replaceStartWith replacement: String) -> Int {
            findLoop()
            let loopSet = Set(loop)

            grid.setValue(at: grid.firstPosition(matching: { $0 == "S" })!, to: replacement)
            grid.gridPoints.forEach { pos in
                if !loopSet.contains(pos) {
                    grid.setValue(at: pos, to: ".")
                }
            }

            let size = grid.size
            var numEnclosed = 0

            for y in 0..<size.y {
                for x in 0..<size.x {
                    let pos = IntPoint(x: x, y: y)
                    if !loopSet.contains(pos) {
                        var isEven = true
                        for x2 in (x + 1)...size.x {
                            if ["|", "L", "J"].contains(grid.getValue(at: IntPoint(x: x2, y: y))) {
                                isEven.toggle()
                            }
                        }

                        numEnclosed += isEven ? 0 : 1
                    }
                }
            }

            return numEnclosed
        }
    }
}
