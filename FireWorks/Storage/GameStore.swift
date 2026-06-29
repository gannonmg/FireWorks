//
//  GameStore.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/25/26.
//

import Foundation

protocol GameStorageInterface: Actor {
    func loadSummaries() async throws(GameStoreError) -> [GameSummary]
    func loadGame(id: GameID) async throws(GameStoreError) -> PersistedGame
    @discardableResult func saveGame(state: GameState) async throws(GameStoreError) -> PersistedGame
    func deleteGame(id: GameID) async throws(GameStoreError)
}

struct NewGameConfig {
    let players: [Player]
    /*
     Settings to add
     - Game Mode (allow play until all cards are played, or add extra suit, or wild suit)
     - Lives
     */
}

// MARK: - GameStore
/**
 Observable GameStore to be propogated via the environment.
 Accepts a generic GameStorageInterface that handles the storing and retrieving of games.
 */

@MainActor
@Observable
final class GameStore {

    // MARK: Properties
    private(set) var summaries: [GameSummary] = []
    private(set) var gamesByID: [GameID: GameState] = [:]

    // MARK: Init
    private let storage: any GameStorageInterface

    init(storage: any GameStorageInterface) {
        self.storage = storage
    }

    // MARK: Actions
    func loadSummaries() async throws {
        summaries = try await storage.loadSummaries()
            .sorted { $0.lastUpdatedAt > $1.lastUpdatedAt }
    }

    func loadGame(gameID: GameID) async throws -> GameState {
        if let cached = gamesByID[gameID] { return cached }
        
        let persisted = try await storage.loadGame(id: gameID)
        gamesByID[gameID] = persisted.gameState
        upsertSummary(persisted.summary)
        return persisted.gameState
    }

    func createGame(
        config: NewGameConfig
    ) async throws -> GameState {
        let state = GameState(players: config.players)
        return try await saveGame(gameState: state)
    }

    @discardableResult
    func saveGame(
        gameState: GameState
    ) async throws -> GameState {
        gamesByID[gameState.id] = gameState

        let persisted = try await storage.saveGame(state: gameState)
        upsertSummary(persisted.summary)
        return gameState
    }
}

private extension GameStore {
    func upsertSummary(_ summary: GameSummary) {
        if let index = summaries.firstIndex(where: { $0.id == summary.id }) {
            summaries[index] = summary
        } else {
            summaries.append(summary)
        }

        summaries.sort { $0.lastUpdatedAt > $1.lastUpdatedAt }
    }
}

// MARK: - Session Game Store
// For ongoing development. True persistant storage later.
actor MockGameStorage: GameStorageInterface {
    private var storage: [GameID: PersistedGame] = [:]

    func loadSummaries() async throws(GameStoreError) -> [GameSummary] {
        storage.values.map(\.summary)
    }

    func loadGame(id: GameID) async throws(GameStoreError) -> PersistedGame {
        guard let game = storage[id] else { throw .gameNotFound(id: id) }
        return game
    }

    @discardableResult
    func saveGame(state: GameState) async throws(GameStoreError) -> PersistedGame {
        let persistedGame = storage[state.id]?.updated(with: state) ?? PersistedGame(gameState: state)
        storage[state.id] = persistedGame
        return persistedGame
    }

    func deleteGame(id: GameID) async throws(GameStoreError) {
        storage.removeValue(forKey: id)
    }
}
