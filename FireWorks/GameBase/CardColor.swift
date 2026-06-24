//
//  CardColor.swift
//  Practice
//
//  Created by Matt Gannon on 6/23/26.
//

import SwiftUI

public enum CardColor: CaseIterable, Hashable, Sendable {

    case red, yellow, purple, green, blue

    var emoji: String {
        // ♥️🦋🐼🦖🐝🍓👾
        switch self {
        case .red:    "🍓"
        case .yellow: "🐝"
        case .purple:  "👾"
        case .green:  "🦖"
        case .blue:   "🦋"
        }
    }

    var color: Color {
        switch self {
        case .red: .red
        case .yellow: .yellow
        case .purple: .purple
        case .green: .green
        case .blue: .blue
        }
    }
}
