//
//  PlayerAction.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/23/26.
//

import Foundation
import OrderedCollections

// What a player submits on their turn
public enum PlayerAction: Hashable, Sendable {
    case play(cardID: Card.ID)
    case discard(cardID: Card.ID)
    case giveHint(hint: Hint, toPlayerID: Player.ID)
}

// What happens on player action
public enum GameEvent: Hashable, Sendable {
    case drawn(cardID: Card.ID, playerID: Player.ID)
    case played(cardID: Card.ID, playerID: Player.ID)
    case discarded(cardID: Card.ID, playerID: Player.ID)
    case gaveHint(hint: Hint, toPlayerID: Player.ID, byPlayerID: Player.ID)
}

// Immutable state of the game at turn, including history
public struct GameState: Hashable, Sendable {
    var turnCounter: Int
    /// Counts the number of turns that have begun since the last card was drawn.
    var finalRoundTurnCounter: Int
    var playerOrder: [Player.ID]

    var hintTokens: Int
    var strikes: Int

    var deck: OrderedSet<Card.ID>
    var discardPile: OrderedSet<Card.ID>
    var hands: [Player.ID: [Card.ID]]
    var stacks: [CardColor: [Card.ID]]

    var history: [GameEvent]
    var cardStore: CardStore
    var knowledgeStore: Knowledge.Store
}

extension GameState {
    var currentPlayerID: Player.ID {
        let turnMod = turnCounter % playerOrder.count
        return playerOrder[turnMod]
    }
}

// Stores actual info about the cards (color and number)
public struct CardStore: Hashable, Sendable {
    private let cards: [Card.ID: Card]

    init(cards: [Card]) {
        self.cards = cards.reduce([:]) { partialResult, card in
            var mutableResult = partialResult
            mutableResult[card.id] = card
            return mutableResult
        }
    }

    subscript(_ id: Card.ID) -> Card { cards[id]! }
}

// Tracks whether the color or number of a card has been revealed

public enum Knowledge {
    public enum Kind: Hashable, Sendable {
        case color, number
    }

    public struct Store: Hashable, Sendable {
        private var knownColorIDs: Set<Card.ID>
        private var knownNumberIDs: Set<Card.ID>

        func isKindKnown(for id: Card.ID, kind: Kind) -> Bool {
            switch kind {
            case .color: knownColorIDs.contains(id)
            case .number: knownNumberIDs.contains(id)
            }
        }

        
        /// Adds given IDs to the appropriate knowledge store. Returns a Boolean representing whether any new insertions occured.
        /// - Parameters:
        ///   - ids: An array of Card IDs to be added to the store.
        ///   - kind: The kind of the store that the IDs are to be added to.
        /// - Returns: A Boolean representing whether any new insertions occured
        public mutating func addAndCheckIDs(ids: [Card.ID], for kind: Kind) -> Bool {
            // Inserts the card ids, and maps partial results to `insertionResults: [Bool]`
            let insertionResults: [Bool] = ids.map {
                switch kind {
                case .color: knownColorIDs.insert($0).inserted
                case .number: knownNumberIDs.insert($0).inserted
                }
            }

            // If `inserted` was false for all IDs, this is not a valid play, as no new information was gained.
            return insertionResults.contains(true)
        }
    }
}
