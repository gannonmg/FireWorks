//
//  Rules.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/23/26.
//

import Foundation

enum Rules {
    static let maxLives = 3
    static let maxHints = 8

    static let minPlayers = 2
    static let maxPlayers = 5

    static func cardsPerPlayer(players: Int) -> Int {
        players > 3 ? 4 : 5
    }
}
