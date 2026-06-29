//
//  PersistedGame.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/26/26.
//

import Foundation

struct PersistedGame: Codable {
    let id: GameID
    let createdAt: Date
    private(set) var updatedAt: Date
    private(set) var gameState: GameState
}

extension PersistedGame {
    init(
        gameState: GameState,
        createdAt: Date = .now
    ) {
        self.id = gameState.id
        self.createdAt = createdAt
        self.updatedAt = .now
        self.gameState = gameState
    }

    private mutating func update(with state: GameState) {
        self.updatedAt = .now
        self.gameState = state
    }

    func updated(with state: GameState) -> PersistedGame {
        var copy = self
        copy.update(with: state)
        return copy
    }

    var summary: GameSummary {
        GameSummary(
            id: id,
            title: "Game \(id.uuidString.prefix(4))",
            createdAt: createdAt,
            lastUpdatedAt: updatedAt,
            isCompleted: gameState.isCompleted,
            playerNames: gameState.playerOrder.map(\.uuidString)
        )
    }
}
