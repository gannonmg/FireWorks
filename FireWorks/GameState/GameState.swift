//
//  GameState.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/24/26.
//

import Foundation
import OrderedCollections

/// Immutable state of the game at turn, including per-turn action and effect history.
public struct GameState: Identifiable, Hashable, Sendable, Codable {
    public private(set) var id = UUID()

    let playerOrder: [Player.ID]
    let playerStore: GameElementStore<Player>
    let cardStore: GameElementStore<Card>

    var turnCounter: Int = 0
    var isFinalRound: Bool = false
    /// Counts the number of turns that have begun since the last card was drawn.
    var finalRoundTurnCounter: Int = 0

    var hintTokens: Int = Rules.maxHints
    var strikes: Int = Rules.maxLives

    var deckOrder: OrderedSet<Card.ID>
    var discardPile: OrderedSet<Card.ID> = []
    var hands: [Player.ID: [Card.ID]] = [:]
    var stacks: [CardColor: [Card.ID]] = [:]

    // History of each turn, including the attempted action and resulting effects.
    var turnRecord: [TurnRecord] = []
    var knowledgeStore: Knowledge.Store = Knowledge.Store()
}

extension GameState {
    init(
        players: [Player]
    ) {
        self.playerStore = .init(elements: players)
        self.playerOrder = players.map(\.id)
        let deck = Deck.makeDeck()
        self.cardStore = .init(elements: deck)

        let shuffledDeckIDs = deck.shuffled().map(\.id)
        self.deckOrder = OrderedSet(shuffledDeckIDs)
    }
}

// MARK: - Helpers
extension GameState {
    var currentPlayerID: Player.ID { playerOrder[turnCounter % playerOrder.count] }
    var numberOfPlayers: Int { playerOrder.count }
    var cardsHaveBeenDealt: Bool { hands.keys.count == playerStore.count }

    var isCompleted: Bool {
        return strikes == 0 || (isFinalRound && finalRoundTurnCounter == numberOfPlayers)
    }
}
