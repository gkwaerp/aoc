//
//  Solver_2023_12.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 12/12/2023.
//

import Foundation

final class Solver_2023_12: Solver {

    private var input: [String] = []
    private var cache: [String: Int] = [:]

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsStringArray()
    }

    private func findArrangementCount(in record: String, folded: Bool) -> Int {
        cache = [:]
        let split = record.components(separatedBy: " ")
        let layoutRaw = split[0]
        var groups = split[1].components(separatedBy: ",").compactMap { $0.intValue }


        let layout: [String]
        if folded {
            layout = "\(layoutRaw)?\(layoutRaw)?\(layoutRaw)?\(layoutRaw)?\(layoutRaw)".convertToStringArray()
            groups = groups + groups + groups + groups + groups
        } else {
            layout = layoutRaw.convertToStringArray()
        }

        return count(layout: layout, groups: groups)
    }

    private func count(layout: [String], groups: [Int]) -> Int {
        let cacheKey = layout.joined() + groups.map { String($0) }.joined()
        if let cached = cache[cacheKey] {
            return cached
        }

        // If we have run out of groups, no more branching can be done. If the layout still demands a #, this branch was invalid
        guard groups.isNotEmpty else { return layout.contains(where: { $0 == "#" }) ? 0 : 1}

        // If we still have groups left, but no more layout to branch in, this branch was invalid.
        guard layout.isNotEmpty else { return 0 }

        var result = 0

        let currChar = layout.first!
        let groupSize = groups.first!

        // Get count if we not insert the current group at this location
        if currChar == "." || currChar == "?" {
            result += count(layout: Array(layout.dropFirst()),
                            groups: groups)
        }

        // Get count if we do insert the current group at this location
        if currChar == "?" || currChar == "#" {
            // The remaining layout is large enough to contain the next group
            let layoutIsLargeEnough = layout.count >= groupSize

            // For the next n characters, we don't have a break/split in the layout
            let layoutIsUnbroken = !layout.prefix(groupSize).contains(where: { $0 == "." })

            // If inserting group here would make us collide with a pre-placed group (needs to have at least 1 space between groups)
            let collidesWithNextGroup = layout[safe: groupSize] == "#"

            let layoutCanContainGroup = layoutIsUnbroken && layoutIsLargeEnough
            let isValid = layoutCanContainGroup && !collidesWithNextGroup

            if isValid {
                result += count(layout: Array(layout.dropFirst(groupSize + 1)),
                                groups: Array(groups.dropFirst()))
            }
        }

        cache[cacheKey] = result

        return result
    }

    override func solveFunction1() -> CustomStringConvertible {
        input
            .map { findArrangementCount(in: $0, folded: false) }
            .reduce(0, +)
    }

    override func solveFunction2() -> CustomStringConvertible {
        input
            .map { findArrangementCount(in: $0, folded: true) }
            .reduce(0, +)
    }
}

extension Solver_2023_12: TestableDay {
    func runTests() {
        let input = """
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
"""
            .components(separatedBy: .newlines)

        let result1 = input.map { findArrangementCount(in: $0, folded: false) }
        let expected1 = [1, 4, 1, 1, 4, 10]
        assert(result1 == expected1)

        let result2 = input.map { findArrangementCount(in: $0, folded: true) }
        let expected2 = [1, 16384, 1, 16, 2500, 506250]
        assert(result2 == expected2)
    }
}

// 7490
