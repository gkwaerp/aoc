//
//  Solver_2023_15.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 15/12/2023.
//

import Foundation

final class Solver_2023_15: Solver {
    private var input: String = ""

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsTextString()
    }

    override func solveFunction1() -> CustomStringConvertible {
        let hashmap = Hashmap()
        return hashmap.getHashSum(for: input)
    }

    override func solveFunction2() -> CustomStringConvertible {
        let hashmap = Hashmap()
        hashmap.handleInstructions(input)
        return hashmap.getFocusingPower()
    }
}

extension Solver_2023_15: TestableDay {
    func runTests() {
        let input = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
        let hashmap1 = Hashmap()
        let result1 = hashmap1.getHashSum(for: input)
        let expected1 = 1320
        assert(result1 == expected1)

        let hashmap2 = Hashmap()
        hashmap2.handleInstructions(input)
        let result2 = hashmap2.getFocusingPower()
        let expected2 = 145
        assert(result2 == expected2)
    }
}

extension Solver_2023_15 {
    private class Hashmap {
        struct Lens {
            let label: String
            let focalLength: Int
        }

        struct Box {
            var lenses: [Lens]
        }

        var boxes: [Box]

        init() {
            boxes = (0..<256).map { _ in Box(lenses: []) }
        }

        func getHashSum(for string: String) -> Int {
            string
                .components(separatedBy: ",")
                .map { getHashValue(for: $0) }
                .reduce(0, +)
        }

        func handleInstructions(_ string: String) {
            let instructions = string.components(separatedBy: ",")
            for instruction in instructions {
                var mutable = instruction
                let focalLength: Int! = mutable.contains(where: { $0 == "=" }) ? String(mutable.popLast()!).intValue! : nil
                let operation = String(mutable.popLast()!)
                let label = mutable
                let boxIndex = getHashValue(for: label)

                if operation == "-" {
                    boxes[boxIndex].lenses.removeAll(where: { $0.label == label })
                } else if operation == "=" {
                    let newLens = Lens(label: label, focalLength: focalLength)
                    if let existingIndex = boxes[boxIndex].lenses.firstIndex(where: { $0.label == label }) {
                        boxes[boxIndex].lenses[existingIndex] = newLens
                    } else {
                        boxes[boxIndex].lenses.append(newLens)
                    }
                } else {
                    fatalError("Invalid operation")
                }
            }
        }

        func getFocusingPower() -> Int {
            (0..<256)
                .map { boxIndex in
                    boxes[boxIndex].lenses.enumerated().map { lensIndex, lens in
                        return (boxIndex + 1) * (lensIndex + 1) * lens.focalLength
                    }
                    .reduce(0, +)
                }
                .reduce(0, +)
        }

        private func getHashValue(for string: String) -> Int {
            var currValue = 0
            string.forEach { char in
                currValue += Int(char.asciiValue!)
                currValue *= 17
                currValue %= 256
            }
            return currValue
        }
    }
}
