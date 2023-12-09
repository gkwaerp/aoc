//
//  Solver_2023_08.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 08/12/2023.
//

import Foundation

final class Solver_2023_08: Solver {
    private var input = ""

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsTextString()
    }

    override func solveFunction1() -> CustomStringConvertible {
        countSteps(input, forGhosts: false)
    }

    override func solveFunction2() -> CustomStringConvertible {
        countSteps(input, forGhosts: true)
    }

    private func countSteps(_ input: String, forGhosts: Bool) -> Int {
        let map = Map(input)
        return forGhosts ? map.countStepsForGhosts() : map.countSteps()
    }
}

extension Solver_2023_08: TestableDay {
    func runTests() {
        let input = """
RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
"""

        let result1 = countSteps(input, forGhosts: false)
        let expected1 = 2
        assert(result1 == expected1)

        let input2 = """
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
"""

        let result2 = countSteps(input2, forGhosts: true)
        let expected2 = 6
        assert(result2 == expected2)
    }
}

extension Solver_2023_08 {
    struct Map {
        let instructions: [String]
        let routes: [String: (String, String)]

        init(_ string: String) {

            let strings = string.components(separatedBy: "\n\n")
            self.instructions = strings[0].convertToStringArray()

            let routeStrings = strings[1].components(separatedBy: .newlines)
            var routes: [String: (String, String)] = [:]

            for string in routeStrings {
                let s = string
                    .replacingOccurrences(of: " =", with: "")
                    .replacingOccurrences(of: "(", with: "")
                    .replacingOccurrences(of: ",", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .components(separatedBy: " ")
                routes[s[0]] = (s[1], s[2])
            }

            self.routes = routes
        }

        func countSteps() -> Int {
            var currentNode = "AAA"
            var numSteps = 0
            var currentInstructionIndex = 0

            while currentNode != "ZZZ" {
                let instruction = instructions[currentInstructionIndex]
                let branch = routes[currentNode]!
                currentNode = instruction == "L" ? branch.0 : branch.1
                currentInstructionIndex += 1
                currentInstructionIndex %= instructions.count
                numSteps += 1
            }

            return numSteps
        }

        func countStepsForGhosts() -> Int {
            routes.keys
                .filter { $0.hasSuffix("A") }
                .map { node in
                    var currentNode = node
                    var numSteps = 0
                    var currentInstructionIndex = 0

                    while !currentNode.hasSuffix("Z") {
                        let instruction = instructions[currentInstructionIndex]
                        let branch = routes[currentNode]!
                        currentNode = instruction == "L" ? branch.0 : branch.1
                        currentInstructionIndex += 1
                        currentInstructionIndex %= instructions.count
                        numSteps += 1
                    }

                    return numSteps
                }
                .reduce(1, { Math.leastCommonMultiple($0, $1)! })
        }
    }
}
