//
//  Solver_2023_09.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 09/12/2023.
//

import Foundation

final class Solver_2023_09: Solver {
    private var input: [String] = []

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsStringArray()
    }

    override func solveFunction1() -> CustomStringConvertible {
        Oasis(input)
            .getPredictedValuesSum(previous: false)
    }

    override func solveFunction2() -> CustomStringConvertible {
        Oasis(input)
            .getPredictedValuesSum(previous: true)
    }
}

extension Solver_2023_09: TestableDay {
    func runTests() {
        let input = """
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"""
            .components(separatedBy: .newlines)

        let oasis1 = Oasis(input)
        let result1 = oasis1.getPredictedValuesSum(previous: false)
        let expected1 = 114
        assert(result1 == expected1)

        let oasis2 = Oasis(input)
        let result2 = oasis2.getPredictedValuesSum(previous: true)
        let expected2 = 2
        assert(result2 == expected2)
    }
}

extension Solver_2023_09 {
    final class Oasis {
        final class History {
            typealias Layer = [Int]
            var values: [Int]

            init(_ string: String) {
                self.values = string.components(separatedBy: .whitespaces).compactMap { $0.intValue }
            }

            func getPredictedValue(previous: Bool) -> Int {
                if previous {
                    values.reverse()
                }

                var layers = generateLayers()
                for i in (1..<(layers.count)).reversed() {
                    let value = layers[i].last! + layers[i - 1].last!
                    layers[i - 1].append(value)
                }

                return layers[0].last!
            }

            private func generateLayers() -> [Layer] {
                var layers: [Layer] = [values]
                while layers.last!.contains(where: { $0 != 0 }) {
                    let currentLayer = layers.last!
                    var nextLayer: Layer = []

                    for i in 1..<currentLayer.count {
                        let delta = currentLayer[i] - currentLayer[i - 1]
                        nextLayer.append(delta)
                    }
                    layers.append(nextLayer)
                }
                return layers
            }
        }

        var histories: [History]

        init(_ strings: [String]) {
            self.histories = strings.map { History($0) }
        }

        func getPredictedValuesSum(previous: Bool) -> Int {
            histories
                .map { $0.getPredictedValue(previous: previous) }
                .reduce(0, +)
        }
    }
}
