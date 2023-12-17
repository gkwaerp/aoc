//
//  Solver_2023_17.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 17/12/2023.
//

import Foundation

final class Solver_2023_17: Solver {
    struct State: Equatable, Hashable {
        let position: IntPoint
        let direction: Direction
        let streak: Int
    }

    private var input: [String] = []

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsStringArray()
    }

    override func solveFunction1() -> CustomStringConvertible {
        findLeastHeatLoss(in: IntGrid(stringArray: input), ultraCrucible: false)
    }

    override func solveFunction2() -> CustomStringConvertible {
        findLeastHeatLoss(in: IntGrid(stringArray: input), ultraCrucible: true)
    }

    private func findLeastHeatLoss(in grid: IntGrid, ultraCrucible: Bool) -> Int {
        let startPos = IntPoint.origin
        let endPos = IntPoint(x: grid.width - 1, y: grid.height - 1)

        var queue = PriorityQueue<(State, Int)>.init(sort: { $0.1 < $1.1 })
        var costs: [State: Int] = [:]

        for direction in [Direction.east, .south] {
            let state = State(position: startPos, direction: direction, streak: 0)
            queue.enqueue((state, 0))
        }

        let minStreak = ultraCrucible ? 4 : 0
        let maxStreak = ultraCrucible ? 10 : 3

        while let (state, heatLoss) = queue.dequeue() {
            if state.position == endPos && state.streak >= minStreak {
                return heatLoss
            }

            let newDirections = [state.direction, state.direction.turn(left: true), state.direction.turn(left: false)]
            for direction in newDirections {
                let nextPos = state.position + direction.movementVector
                guard grid.isWithinBounds(nextPos) else { continue }

                let nextStreak: Int
                if direction == state.direction {
                    if state.streak + 1 > maxStreak {
                        continue
                    }
                    nextStreak = state.streak + 1
                } else {
                    if state.streak < minStreak {
                        continue
                    }
                    nextStreak = 1
                }

                let nextCost = costs[state]! + grid.getValue(at: nextPos)!
                let nextState = State(position: nextPos, direction: direction, streak: nextStreak)
                if nextCost < costs[nextState, default: Int.max] {
                    costs[nextState] = nextCost
                    queue.enqueue((nextState, nextCost))
                }
            }
        }

        fatalError("Unable to find valid path!")
    }
}

extension Solver_2023_17: TestableDay {
    func runTests() {
        let input1 = """
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
"""
            .components(separatedBy: .newlines)

        let grid1 = IntGrid(stringArray: input1)
        let result1 = findLeastHeatLoss(in: grid1, ultraCrucible: false)
        let expected1 = 102
        assert(result1 == expected1)

        let result2 = findLeastHeatLoss(in: grid1, ultraCrucible: true)
        let expected2 = 94
        assert(result2 == expected2)

        let input2 = """
111111111111
999999999991
999999999991
999999999991
999999999991
"""
            .components(separatedBy: .newlines)

        let grid2 = IntGrid(stringArray: input2)
        let result3 = findLeastHeatLoss(in: grid2, ultraCrucible: true)
        let expected3 = 71
        assert(result3 == expected3)
    }
}
