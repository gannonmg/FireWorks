//
//  CardNumber.swift
//  Practice
//
//  Created by Matt Gannon on 6/23/26.
//

public enum CardNumber: Int, CaseIterable, Hashable, Sendable, Codable {

    case one = 1, two, three, four, five

    var amountPerColor: Int {
        switch self {
        case .one:
            return 3
        case .two, .three, .four:
            return 2
        case .five:
            return 1
        }
    }
}
