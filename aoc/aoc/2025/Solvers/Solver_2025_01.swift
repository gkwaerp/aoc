//
//  Solver_2025_01.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 01/12/2025.
//

import Foundation

final class Solver_2025_01: Solver {
    private var input: [String] = []

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsStringArray()
    }

    override func solveFunction1() -> CustomStringConvertible {
        countZeroPoints(input, includeProgressiveZeroes: false)
    }

    override func solveFunction2() -> CustomStringConvertible {
        countZeroPoints(input, includeProgressiveZeroes: true)
    }
    
    func countZeroPoints(_ input: [String], includeProgressiveZeroes: Bool) -> Int {
        var result = 0
        var currValue = 50
        for line in input {
            let dir = line.first!
            let rotations = Int(line.dropFirst())!
            let wholeRotations = rotations / 100
            
            if includeProgressiveZeroes {
                result += wholeRotations
            }

            let remainingRotations = rotations % 100
            
            if dir == "L" {
                let comp: (Int, Int) -> Bool = includeProgressiveZeroes ? (>=) : (==)
                if comp(remainingRotations, currValue) && currValue != 0 {
                    result += 1
                }
                currValue -= remainingRotations
                if currValue < 0 {
                    currValue += 100
                }
            } else {
                let comp: (Int, Int) -> Bool = includeProgressiveZeroes ? (<=) : (==)
                if comp(100 - currValue, remainingRotations) {
                    result += 1
                }
                currValue += remainingRotations
                currValue %= 100
            }
        }
        
        return result
    }
}

extension Solver_2025_01: TestableDay {
    func runTests() {
        let input = """
L68
L30
R48
L5
R60
L55
L1
L99
R14
L82
"""
            .components(separatedBy: .newlines)

        let result1 = countZeroPoints(input, includeProgressiveZeroes: false)
        let expected1 = 3
        assert(result1 == expected1)

        let result2 = countZeroPoints(input, includeProgressiveZeroes: true)
        let expected2 = 6
        assert(result2 == expected2)
    }
}
