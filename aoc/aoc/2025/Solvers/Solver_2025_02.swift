//
//  Solver_2025_02.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 02/12/2025.
//

import Foundation

final class Solver_2025_02: Solver {
    private var input: String = ""

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsTextString()
    }

    override func solveFunction1() -> CustomStringConvertible {
        sumInvalidIds(input, replaceAll: false)
    }

    override func solveFunction2() -> CustomStringConvertible {
        sumInvalidIds(input, replaceAll: true)
    }
    
    func sumInvalidIds(_ input: String, replaceAll: Bool) -> Int {
        var result = 0
        let ranges = input
            .components(separatedBy: ",")
            .map { $0.split(separator: "-") }
            .map { ClosedRange(uncheckedBounds: (Int($0[0])!, Int($0[1])!)) }

        ranges.forEach {
            result += $0
                .filter { !isValidId($0, replaceAll: replaceAll) }
                .reduce(0, +)
        }
        
        return result
    }
    
    func isValidId(_ id: Int, replaceAll: Bool) -> Bool {
        if id < 10 {
            return true
        }

        let stringed = "\(id)"
        let range = 1...(stringed.count / 2)
        for i in range {
            let numRepetitions = stringed.count / i
            if !replaceAll && numRepetitions != 2 {
                continue
            }

            let endIndex = stringed.index(stringed.startIndex, offsetBy: i)
            let substring = String(stringed[..<endIndex])
            let candidate = String(repeating: substring, count: numRepetitions)
            if candidate == stringed {
                return false
            }
        }

        return true
    }
}

extension Solver_2025_02: TestableDay {
    func runTests() {
        let input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"

        let result1 = sumInvalidIds(input, replaceAll: false)
        let expected1 = 1227775554
        assert(result1 == expected1)

        
        let result2 = sumInvalidIds(input, replaceAll: true)
        let expected2 = 4174379265
        assert(result2 == expected2)
    }
}
