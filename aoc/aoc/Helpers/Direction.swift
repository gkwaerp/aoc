//
//  Direction.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 29/11/2022.
//

import Foundation

/// Note: North is negative `y` / South is positive `y`
enum Direction: Int, CaseIterable, Hashable {
    case north = 1
    case south = 2
    case west = 3
    case east = 4

    var movementVector: IntPoint {
        switch self {
        case .north: return IntPoint(x: 0, y: -1)
        case .south: return IntPoint(x: 0, y: 1)
        case .west: return IntPoint(x: -1, y: 0)
        case .east: return IntPoint(x: 1, y: 0)
        }
    }

    var reversed: Direction {
        switch self {
        case .north: return .south
        case .south: return .north
        case .east: return .west
        case .west: return .east
        }
    }

    mutating func turn(left: Bool) {
        switch self {
        case .north: self = left ? .west : .east
        case .south: self = left ? .east : .west
        case .east: self = left ? .north : .south
        case .west: self = left ? .south : .north
        }
    }

    init?(string: String) {
        switch string {
        case "U", "N", "^": self = .north
        case "D", "S", "v": self = .south
        case "R", "E", ">": self = .east
        case "L", "W", "<": self = .west
        default: return nil
        }
    }

    var arrowString: String {
        switch self {
        case .north: return "^"
        case .south: return "v"
        case .east: return ">"
        case .west: return "<"
        }
    }
}
