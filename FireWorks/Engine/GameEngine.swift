//
//  GameEngine.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/24/26.
//

import Foundation
import OrderedCollections

public enum GameEngine {
    public static func apply(
        playerAction: PlayerAction,
        to gameState: GameState
    ) throws(GameEngineError) -> GameState {

        var stateCopy = gameState

        switch playerAction {
        case .play(let cardID):
            stateCopy = try playCard(cardID: cardID, gameState: stateCopy)

            // Append this move to the game log
            stateCopy.history.append(.played(cardID: cardID, playerID: stateCopy.currentPlayerID))

        case .discard(let cardID):
            stateCopy = try discard(cardID: cardID, gameState: stateCopy)

            // Append this move to the game log
            stateCopy.history.append(.discarded(cardID: cardID, playerID: stateCopy.currentPlayerID))

        case .giveHint(let hint, let toPlayerID):
            stateCopy = try giveHint(hint: hint, toPlayerID: toPlayerID, gameState: stateCopy)

            // Append this move to the game log
            stateCopy.history.append(.gaveHint(hint: hint, toPlayerID: toPlayerID, byPlayerID: stateCopy.currentPlayerID))
        }

        // Assuming we haven't thrown an error, advance to next turn
        stateCopy.turnCounter += 1

        return stateCopy
    }

    // MARK: - Primary Actions

    // MARK: Play Card
    internal static func playCard(cardID: Card.ID, gameState: GameState) throws(GameEngineError) -> GameState {
        var stateCopy = gameState

        // Get card via Card ID and CardStore
        let card = stateCopy.cardStore[cardID]

        // Card is removed from hand, irrelevant whether it can be played
        stateCopy = try removeCardFromHand(
            cardID: cardID,
            playerID: gameState.currentPlayerID,
            gameState: gameState
        )

        let (cardWasPlayed, updatedState) = try attemptAddCardToTableau(card: card, gameState: stateCopy)
        stateCopy = updatedState

        if cardWasPlayed {
            // Award a hint if this card completed the stack
            let stackWasCompleted = stackIsComplete(for: card.color, gameState: stateCopy)
            if stackWasCompleted {
                stateCopy = maybeGainHint(gameState: stateCopy)
            }
        } else {
            // Card is sent to discard pile
            stateCopy = try moveCardToDiscard(cardID: cardID, gameState: stateCopy)

            // Life is burned
            stateCopy = try loseStrike(gameState: stateCopy)
        }

        // Player must draw a new card
        stateCopy = try drawCard(gameState: stateCopy)

        return stateCopy
    }

    // MARK: Discard
    /// Handles removing the card from the player's hand and adding it to the discard pile
    internal static func discard(
        cardID: Card.ID,
        gameState: GameState
    ) throws(GameEngineError) -> GameState {
        var stateCopy = gameState

        // Card is removed from the player's hand
        stateCopy = try removeCardFromHand(
            cardID: cardID,
            playerID: stateCopy.currentPlayerID,
            gameState: stateCopy
        )

        // And sent to discard pile
        stateCopy = try moveCardToDiscard(cardID: cardID, gameState: stateCopy)

        // Reward a hint for the discard
        stateCopy = maybeGainHint(gameState: stateCopy)

        // Player must draw a new card
        stateCopy = try drawCard(gameState: stateCopy)

        return stateCopy
    }

    // MARK: Give Hint
    internal static func giveHint(
        hint: Hint,
        toPlayerID: Player.ID,
        gameState: GameState
    ) throws(GameEngineError) -> GameState {
        guard 0 < gameState.hintTokens else { throw .outOfHintTokens }
        if gameState.currentPlayerID == toPlayerID { throw .attemptedSelfHint(playerID: toPlayerID) }

        var stateCopy = gameState

        // Create an array of IDs for the player's hand where the card matches the type and value of the hint given
        let filteredHandIDs = stateCopy.hands[toPlayerID, default: []]
            // Get card info via IDs
            .map { stateCopy.cardStore[$0] }
            // Filter cards based on the type and value of the hint
            .filter { card in
                switch hint {
                case .color(let cardColor):
                    card.color == cardColor
                case .number(let cardNumber):
                    card.number == cardNumber
                }
            }
            // Reduce back into array of Card.IDs
            .map(\.id)

        // Make sure there is at least 1 card matching the info given
        guard !filteredHandIDs.isEmpty else {
            throw .invalidHint(reason: .noMatchingCard)
        }

        let kind: Knowledge.Kind = switch hint {
        case .color: .color
        case .number: .number
        }

        // Add IDs to the knowledge store.
        let addedNewIDs = stateCopy.knowledgeStore.addAndCheckIDs(
            ids: filteredHandIDs,
            for: kind
        )

        // If all IDs are already in the appropriate store, throw error
        guard addedNewIDs else {
            throw .invalidHint(reason: .noNewInfo)
        }

        // If hint was valid, expend token
        stateCopy.hintTokens -= 1

        return stateCopy
    }


    // MARK: - Helpers
    internal static func removeCardFromHand(
        cardID: Card.ID,
        playerID: Player.ID,
        gameState: GameState
    ) throws(GameEngineError) -> GameState {
        let handContainsCard = gameState.hands[playerID]?.contains(cardID) ?? false
        guard handContainsCard else {
            throw .cardNotInHand(cardID: cardID, playerID: playerID)
        }

        var stateCopy = gameState
        stateCopy.hands[playerID]?
            .removeAll(where: { $0 == cardID })
        return stateCopy
    }

    
    /// Attempts to add the card to the tableau. Response includes a Bool representing whether the play was legal or not, and the updated GameState.
    ///
    /// - Parameters:
    ///   - card: The card being played.
    ///   - gameState: The current state of the game.
    /// - Returns: A Bool representing whether the play was legal or not, and the updated GameState.
    internal static func attemptAddCardToTableau(
        card: Card,
        gameState: GameState
    ) throws(GameEngineError) -> (Bool, GameState) {
        
        // Check if card can be played legally
        let cardIsPlayable = isCardPlayable(
            card: card,
            stackHeight: gameState.stacks[card.color, default: []].count
        )

        if cardIsPlayable {
            var stateCopy = gameState
            // Add the card to the stack
            stateCopy.stacks[card.color, default: []].append(card.id)
            return (true, stateCopy)
        } else {
            return (false, gameState)
        }
    }

    /// Determines if a stack is complete by comparing the max card value to the height of the stack
    internal static func stackIsComplete(for color: CardColor, gameState: GameState) -> Bool {
        let highestCardValue = CardNumber.allCases.map(\.rawValue).max()
        let stackHeight = gameState.stacks[color, default: []].count
        return highestCardValue == stackHeight
    }

    internal static func moveCardToDiscard(cardID: Card.ID, gameState: GameState) throws(GameEngineError) -> GameState {
        var stateCopy = gameState
        let inserted = stateCopy.discardPile.append(cardID).inserted
        if inserted {
            return stateCopy
        } else {
            throw .illegalDiscard(cardID: cardID)
        }
    }

    /// Evaluates if a given card is playable based on the height of its color's stack.
    ///
    /// - Parameters:
    ///   - card: The card being played, including color and number information.
    ///   - stackHeight: The height of the color's current stack in the game tableau.
    /// - Returns: Boolean value representing if the card is playable.
    internal static func isCardPlayable(card: Card, stackHeight: Int) -> Bool {
        let numberValue = card.number.rawValue
        return stackHeight == numberValue - 1
    }

    internal static func loseStrike(gameState: GameState) throws(GameEngineError) -> GameState {
        var stateCopy = gameState
        stateCopy.strikes -= 1

        if stateCopy.strikes <= 0 {
            throw .gameOver(reason: .lastStrike, finalState: stateCopy)
        }

        return stateCopy
    }

    /// Draws a card for the current player and returns the updated state.
    internal static func drawCard(gameState: GameState) throws(GameEngineError) -> GameState {
        guard !gameState.deck.isEmpty else { return gameState }

        let currentPlayerID = gameState.currentPlayerID

        // Make sure the player's hand is not already full, else throw an error.
        let playerHandSize = gameState.hands[currentPlayerID, default: []].count
        let maxHandSize = Rules.cardsPerPlayer(players: gameState.playerOrder.count)
        guard playerHandSize < maxHandSize else {
            throw .exceededHandLimit(playerId: gameState.currentPlayerID)
        }

        var stateCopy = gameState

        let topCardID = stateCopy.deck.removeLast()
        stateCopy.hands[currentPlayerID, default: []].append(topCardID)
        stateCopy.history.append(.drawn(cardID: topCardID, playerID: currentPlayerID))
        return stateCopy
    }

    /// Returns a hint token to the players if they do not already have the maximum allowed.
    internal static func maybeGainHint(gameState: GameState) -> GameState {
        guard gameState.hintTokens < Rules.maxHints else { return gameState }
        var stateCopy = gameState
        stateCopy.hintTokens += 1
        return stateCopy
    }
}
