//
//  GameSession.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/23/26.
//

import Observation

enum GameSessionError: Error {
    case noHandForPlayer(Player.ID)
    case engineError(GameEngineError)
}

@Observable
final class GameSession {

    private(set) var gameState: GameState
    private(set) var sessionError: GameSessionError?

    init(
        gameState: GameState
    ) {
        self.gameState = gameState
    }

    // MARK: Actions
    func dealCards() {
        do {
            self.gameState = try GameEngine.apply(gameAction: .dealCards, to: gameState)
        } catch {
            self.sessionError = .engineError(error)
        }
    }

    func testDraw() {
        do {
            let id = hand(for: players.first!).first!.id
            self.gameState = try GameEngine.apply(gameAction: .play(cardID: id), to: gameState)
//            Task {
//                try await Task.sleep(for: .seconds(1))
//                self.gameState = try GameEngine.apply(gameAction: .play(cardID: id), to: gameState)
//            }
        } catch {
            self.sessionError = .engineError(error)
        }
    }

    // MARK: Helpers
    var players: [Player] { gameState.playerStore.values }

    func hand(for player: Player) -> [Card] {
        guard let cardIDs = gameState.hands[player.id],
              gameState.cardsHaveBeenDealt
        else {
            self.sessionError = .noHandForPlayer(player.id)
            return []
        }

        return cardIDs.map { gameState.cardStore[$0] }
    }

    // Returns the first three cards in the deck to preview on the board
    var deckCards: [Card] {
        gameState.deckOrder
            .prefix(upTo: 3)
            .map { gameState.cardStore[$0] }
    }


}
