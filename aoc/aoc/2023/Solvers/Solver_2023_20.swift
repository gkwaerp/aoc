//
//  Solver_2023_20.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 20/12/2023.
//

import Foundation

final class Solver_2023_20: Solver {
    private var input: [String] = []

    override func didLoadFunction() {
        input = defaultInputFileString.loadAsStringArray()
    }

    override func solveFunction1() -> CustomStringConvertible {
        let modules = parse(input)
        return getPulseFactor(for: modules, numTimes: 1000)
    }

    override func solveFunction2() -> CustomStringConvertible {
        let modules = parse(input)
        return findNumPressesForRx(for: modules)
    }

    private func parse(_ input: [String]) -> [String: Module] {
        let button = Module(name: "button", kind: .button, destinations: ["broadcaster"])
        let output = Module(name: "output", kind: .debug, destinations: [])
        var moduleDict: [String: Module] = [
            "button": button,
            "output": output
        ]

        let modules = input.map { string in
            let kind: Module.Kind
            if string.hasPrefix("%") {
                kind = .flipFlop
            } else if string.hasPrefix("&") {
                kind = .conjunction
            } else {
                kind = .broadcaster
            }

            let split = string
                .replacingOccurrences(of: "%", with: "")
                .replacingOccurrences(of: "&", with: "")
                .components(separatedBy: " -> ")
            let name = split[0]
            let destinations = split[1].components(separatedBy: ", ")

            return Module(name: name, kind: kind, destinations: destinations)
        }

        modules.forEach { moduleDict[$0.name] = $0 }

        modules.forEach { module in
            module.destinations.forEach { destination in
                if moduleDict.keys.contains(where: { $0 == destination }) {
                    moduleDict[destination]!.memory[module.name] = .low
                }
            }
        }


        return moduleDict
    }

    private func getPulseFactor(for modules: [String: Module], numTimes: Int) -> Int {
        var numPulses: [Module.Pulse: Int] = [:]

        for _ in 0..<numTimes {
            /// Pulse, Target, Source
            var queue: [(Module.Pulse, String, String)] = [(.low, "broadcaster", "button")]
            while queue.isNotEmpty {
                let (pulse, target, source) = queue.removeFirst()
                numPulses[pulse, default: 0] += 1

                guard let targetModule = modules[target] else { continue }
                if let pulseToSend = targetModule.pulseToSend(received: pulse, source: source) {
                    targetModule.destinations.forEach { destination in
                        queue.append((pulseToSend, destination, target))
                    }
                }
            }
        }

        return numPulses[.low]! * numPulses[.high]!
    }

    private func findNumPressesForRx(for modules: [String: Module]) -> Int {
        var count = 0
        var cycles: [String: Int] = [:]
        while true {
            count += 1

            /// Pulse, Target, Source
            var queue: [(Module.Pulse, String, String)] = [(.low, "broadcaster", "button")]
            while queue.isNotEmpty {
                let (pulse, target, source) = queue.removeFirst()

                let toRx = modules.first(where: { $0.value.destinations.contains { $0 == "rx" } })!.value
                let contributors = toRx.memory.keys
                if contributors.contains(where: { $0 == source }) && pulse == .high {
                    cycles[source] = count
                    if cycles.count == contributors.count {
                        return cycles.values.reduce(1, { Math.leastCommonMultiple($0, $1)! })
                    }
                }

                guard let targetModule = modules[target] else { continue }
                if let pulseToSend = targetModule.pulseToSend(received: pulse, source: source) {
                    targetModule.destinations.forEach { destination in
                        queue.append((pulseToSend, destination, target))
                    }
                }
            }
        }
    }
}


extension Solver_2023_20: TestableDay {
    func runTests() {
        let input1 = """
broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a
"""
            .components(separatedBy: .newlines)

        let modules1 = parse(input1)
        let result1 = getPulseFactor(for: modules1, numTimes: 1000)
        let expected1 = 32000000
        assert(result1 == expected1)

        let input2 = """
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
"""
            .components(separatedBy: .newlines)
        let modules2 = parse(input2)
        let result2 = getPulseFactor(for: modules2, numTimes: 1000)
        let expected2 = 11687500
        assert(result2 == expected2)
    }
}


extension Solver_2023_20 {
    class Module {
        enum Kind {
            case button
            case flipFlop
            case conjunction
            case broadcaster
            case debug
        }

        enum Pulse {
            case low
            case high
        }

        let name: String
        let kind: Kind
        let destinations: [String]
        var memory: [String: Pulse] // Conjunction only
        var isOn: Bool // FlipFlop only

        init(name: String, kind: Kind, destinations: [String]) {
            self.name = name
            self.kind = kind
            self.destinations = destinations
            self.memory = [:]
            self.isOn = false
        }

        func pulseToSend(received: Pulse?, source: String) -> Pulse? {
            switch kind {
            case .button:
                return .low
            case .debug: return nil
            case .flipFlop:
                guard let received else { fatalError("FlipFlop didn't receive a pulse before attempting to send?") }
                if received == .high {
                    return nil
                } else {
                    isOn.toggle()
                    return isOn ? .high : .low
                }
            case .conjunction:
                guard let received else { fatalError("Conjunction didn't receive a pulse before attempting to send?") }
                memory[source] = received
                return memory.values.allSatisfy({ $0 == .high }) ? .low : .high
            case .broadcaster:
                guard let received else { fatalError("Broadcaster didn't receive a pulse before attempting to send?") }
                return received
            }
        }
    }
}
