//
//  Solver_2023_19.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 19/12/2023.
//

import Foundation

final class Solver_2023_19: Solver {
    var input: String = ""

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsTextString()
    }

    override func solveFunction1() -> CustomStringConvertible {
        let (workflows, parts) = parse(input)
        return getAcceptedSum(for: workflows, with: parts)
    }

    override func solveFunction2() -> CustomStringConvertible {
        let (workflows, _) = parse(input)
        return getDistinctAcceptedCombinations(for: workflows)
    }

    private func parse(_ string: String) -> ([Workflow], [Part]) {
        let split = string.components(separatedBy: "\n\n")
        let workflows = split[0]
            .components(separatedBy: .newlines)
            .map { Workflow($0) }
        let parts = split[1]
            .components(separatedBy: .newlines)
            .map { Part($0) }

        return (workflows, parts)
    }

    private func getAcceptedSum(for workflows: [Workflow], with parts: [Part]) -> Int {
        var workflowLookup: [String: Workflow] = [:]
        workflows.forEach { workflowLookup[$0.name] = $0 }

        var accepted: [Part] = []
        var workflowsWithParts: Set<String> = ["in"]
        parts.forEach { workflowLookup["in"]?.parts.append($0) }

        while let workflowName = workflowsWithParts.popFirst() {
            let workflow = workflowLookup[workflowName]!
            while let part = workflow.parts.popLast() {
                for rule in workflow.rules {
                    guard let result = rule.evaluate(part: part) else { continue }
                    if result == "A" {
                        accepted.append(part)
                    } else if result != "R" {
                        workflowLookup[result]!.parts.append(part)
                        workflowsWithParts.insert(result)
                    }
                    break
                }
            }
        }

        return accepted
            .map { $0.ratingSum }
            .reduce(0, +)
    }

    private func getDistinctAcceptedCombinations(for workflows: [Workflow]) -> Int {
        var workflowLookup: [String: Workflow] = [:]
        workflows.forEach { workflowLookup[$0.name] = $0 }

        var ranges: [String: ClosedRange<Int>] = [:]
        "xmas".convertToStringArray().forEach { ranges[$0] = 1...4000 }

        var accepted: [Range] = []

        let root = Range(name: "in", ranges: ranges)
        var queue = [root]
        while let range = queue.popLast() {
            let splits = split(range, workflows: workflowLookup)
            accepted.append(contentsOf: splits.filter { $0.name == "A" })
            queue.append(contentsOf: splits)
        }

        return accepted
            .map { $0.matches }
            .reduce(0, +)
    }

    private func split(_ range: Range, workflows: [String: Workflow]) -> [Range] {
        guard let workflow = workflows[range.name] else { return [] }

        var remainingRanges = range.ranges
        var result = [Range]()
        for rule in workflow.rules {
            if let stat = rule.stat {
                let range = remainingRanges[stat]!
                let newRange = Range(name: rule.outcome, ranges: remainingRanges)

                if rule.comparitor == .lessThan {
                    newRange.ranges[stat] = range.lowerBound ... rule.value! - 1
                    remainingRanges[stat] = rule.value! ... range.upperBound
                } else {
                    newRange.ranges[stat] = rule.value! + 1 ... range.upperBound
                    remainingRanges[stat] = range.lowerBound ... rule.value!
                }
                result.append(newRange)
            } else {
                result.append(Range(name: rule.outcome, ranges: remainingRanges))
            }
        }
        return result
    }
}

extension Solver_2023_19: TestableDay {
    func runTests() {
        let input = """
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
"""

        let (workflows, parts) = parse(input)
        let result1 = getAcceptedSum(for: workflows, with: parts)
        let expected1 = 19114
        assert(result1 == expected1)

        let result2 = getDistinctAcceptedCombinations(for: workflows)
        let expected2 = 167409079868000
        assert(result2 == expected2)
    }
}

extension Solver_2023_19 {
    struct Rule {
        enum Comparitor: String {
            case lessThan = "<"
            case greaterThan = ">"

            var op: (Int, Int) -> (Bool) {
                switch self {
                case .lessThan: return (<)
                case .greaterThan: return (>)
                }
            }
        }
        let stat: String?
        let value: Int?
        let comparitor: Comparitor?
        let outcome: String

        init(_ string: String) {
            let split = string.components(separatedBy: ":")
            if split.count == 1 {
                outcome = split[0]
                stat = nil
                comparitor = nil
                value = nil
            } else {
                outcome = split[1]
                if split[0].contains(where: { $0 == ">" }) {
                    let ruleSplit = split[0].components(separatedBy: ">")
                    stat = ruleSplit[0]
                    value = ruleSplit[1].intValue!
                    comparitor = .greaterThan
                } else {
                    let ruleSplit = split[0].components(separatedBy: "<")
                    stat = ruleSplit[0]
                    value = ruleSplit[1].intValue!
                    comparitor = .lessThan
                }
            }
        }

        func evaluate(part: Part) -> String? {
            guard let comparitor else { return outcome }
            return comparitor.op(part.stats[stat!]!, value!) ? outcome : nil
        }
    }

    class Workflow: Hashable, Equatable {
        let name: String
        let rules: [Rule]
        var parts: [Part]

        init(_ string: String) {
            let split = string
                .replacingOccurrences(of: "}", with: "")
                .components(separatedBy: "{")

            self.name = split[0]
            self.rules = split[1]
                .components(separatedBy: ",")
                .map { Rule($0) }
            self.parts = []
        }

        static func == (lhs: Workflow, rhs: Workflow) -> Bool {
            return lhs.name == rhs.name
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
    }

    struct Part {
        var stats: [String: Int]

        init(_ string: String) {
            stats = [:]
            string
                .replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: "}", with: "")
                .components(separatedBy: ",")
                .forEach { s in
                    let stat = s.components(separatedBy: "=")
                    stats[stat[0]] = stat[1].intValue!
                }
        }

        init(statName: String, statValue: Int) {
            stats = [statName: statValue]
        }

        var ratingSum: Int {
            stats.values.reduce(0, +)
        }
    }

    private final class Range {
        let name: String
        var ranges: [String: ClosedRange<Int>]

        init(name: String, ranges: [String : ClosedRange<Int>]) {
            self.name = name
            self.ranges = ranges
        }

        var matches: Int {
            ranges.values.map { $0.upperBound - $0.lowerBound + 1 }.reduce(1, *)
        }
    }
}
