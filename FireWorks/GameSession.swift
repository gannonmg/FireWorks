//
//  GameSession.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/23/26.
//

import Observation

@Observable
final class GameSession {

    private(set) var gameState: GameState

    init(
        gameState: GameState
    ) {
        self.gameState = gameState
    }
}
