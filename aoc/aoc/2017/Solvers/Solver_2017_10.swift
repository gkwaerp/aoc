//
//  Solver_2017_10.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 16/11/2023.
//

import Foundation

final class Solver_2017_10: Solver {
    final class Hasher {
        let listSize: Int
        var skipSize: Int
        let inputLengths: [Int]
        var list: [Int]
        var currentIndex: Int

        init(listSize: Int, inputLengths: [Int]) {
            self.listSize = listSize
            self.skipSize = 0
            self.inputLengths = inputLengths
            self.list = (0..<listSize).map { $0 }
            self.currentIndex = 0
        }

        init(listSize: Int, string: String) {
            self.listSize = listSize
            self.skipSize = 0
            self.inputLengths = string.map { Int($0.asciiValue!) } + [17, 31, 73, 47, 23]
            self.list = (0..<listSize).map { $0 }
            self.currentIndex = 0
        }

        func runHash(numRounds: Int = 1) {
            (0..<numRounds).forEach { _ in
                inputLengths.forEach { inputLength in
                    guard inputLength < listSize else { return }

                    var reversedSublist = [Int]()
                    for i in 0..<inputLength {
                        let index = (currentIndex + i) % listSize
                        reversedSublist.append(list[index])
                    }
                    reversedSublist.reverse()

                    for i in 0..<inputLength {
                        let index = (currentIndex + i) % listSize
                        list[index] = reversedSublist[i]
                    }

                    currentIndex += inputLength + skipSize
                    currentIndex %= listSize
                    skipSize += 1
                }
            }
        }

        func getHashValue() -> Int {
            return list[0] * list[1]
        }

        private func getDenseHash() -> [Int] {
            var denseHash = [Int]()
            stride(from: 0, through: 256 - 16, by: 16).forEach { blockStartIndex in
                let output = (blockStartIndex..<(blockStartIndex + 16)).reduce(0, { $0 ^ list[$1] })
                denseHash.append(output)
            }
            return denseHash
        }

        func getHexString() -> String {
            let denseHash = getDenseHash()
            return denseHash.map { String(format: "%02X", $0) }.joined().lowercased()
        }
    }

    private var input = ""

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsTextString()
    }

    override func solveFunction1() -> CustomStringConvertible {
        let intInput = input.components(separatedBy: ",").map { Int($0)! }
        let hasher = Hasher(listSize: 256, inputLengths: intInput)
        hasher.runHash()
        return hasher.getHashValue()
    }

    override func solveFunction2() -> CustomStringConvertible {
        let hasher = Hasher(listSize: 256, string: input)
        hasher.runHash(numRounds: 64)
        return hasher.getHexString()
    }
}

extension Solver_2017_10: TestableDay {
    func runTests() {
        let inputLengths = [3, 4, 1, 5]
        let hasher = Hasher(listSize: 5, inputLengths: inputLengths)
        hasher.runHash()
        let hashValue = hasher.getHashValue()
        let expected = 12
        assert(hashValue == expected)

        let inputs2 = ["", "AoC 2017", "1,2,3", "1,2,4"]
        let results2 = inputs2.map { input in
            let hasher = Hasher(listSize: 256, string: input)
            hasher.runHash(numRounds: 64)
            return hasher.getHexString()
        }

        let expected2 = [
            "a2582a3a0e66e6e86e3812dcb672a272",
            "33efeb34ea91902bb2f59c9920caa6cd",
            "3efbe78a8d82f29979031a4aa0b16a9d",
            "63960835bcdc130f0b66d7ff4f6a5a8e"
        ]
        assert(results2 == expected2)
    }
}
