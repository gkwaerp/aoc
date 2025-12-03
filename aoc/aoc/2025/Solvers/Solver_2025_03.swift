//
//  Solver_2025_03.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 03/12/2025.
//

import Foundation

final class Solver_2025_03: Solver {
    private var input: [String] = []

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsStringArray()
    }

    override func solveFunction1() -> CustomStringConvertible {
        getTotalJoltage(input, numBatteries: 2)
    }

    override func solveFunction2() -> CustomStringConvertible {
        getTotalJoltage(input, numBatteries: 12)
    }
    
    func getTotalJoltage(_ input: [String], numBatteries: Int) -> Int {
        input.map { getJoltageInBank($0, numBatteries: numBatteries) }.reduce(0, +)
    }
    
    func getJoltageInBank(_ bank: String, numBatteries: Int) -> Int {
        let array = bank.convertToStringArray().map { $0.intValue! }

        var result = 0
        var currentIndex = array.startIndex
        for i in 1...numBatteries {
            let subArray = array[currentIndex..<array.endIndex.advanced(by: -(numBatteries - i))]
            let bestValue = subArray.max()!
            currentIndex = subArray.firstIndex(of: bestValue)!.advanced(by: 1)
            result = result * 10 + bestValue
        }

        return result
    }
}

extension Solver_2025_03: TestableDay {
    func runTests() {
        let input = """
987654321111111
811111111111119
234234234234278
818181911112111
"""
            .components(separatedBy: .newlines)

        let result1 = getTotalJoltage(input, numBatteries: 2)
        let expected1 = 357
        assert(result1 == expected1)
        
        let result2 = getTotalJoltage(input, numBatteries: 12)
        let expected2 = 3121910778619
        assert(result2 == expected2)
    }
}
