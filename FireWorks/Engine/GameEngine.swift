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
        gameAction: GameAction,
        to gameState: GameState
    ) throws(GameEngineError) -> GameState {
        let actingPlayerID = gameState.currentPlayerID
        var stateCopy = gameState
        var events: [GameEvent] = []

        switch gameAction {
        case .dealCards:
            try dealCards(gameState: &stateCopy, events: &events)

        case .play(let cardID):
            try playCard(cardID: cardID, gameState: &stateCopy, events: &events)

        case .discard(let cardID):
            try discard(cardID: cardID, gameState: &stateCopy, events: &events)

        case .giveHint(let hint, let toPlayerID):
            try giveHint(hint: hint, toPlayerID: toPlayerID, gameState: &stateCopy, events: &events)
        }

        // Check if we have completed the final round of the game
        advanceFinalRoundCounterIfNeeded(gameState: &stateCopy)

        events.append(stateCopy.isCompleted ? .gameEnded : .turnAdvanced)

        appendHistory(
            for: gameAction,
            playerID: actingPlayerID,
            events: events,
            gameState: &stateCopy
        )

        // Assuming we haven't thrown an error, advance to next turn
        stateCopy.turnCounter += 1

        return stateCopy
    }

    // MARK: - Primary Actions

    // MARK: Deal Hands
    internal static func dealCards(
        gameState: inout GameState,
        events: inout [GameEvent]
    ) throws(GameEngineError) {
        let playerCount = gameState.playerOrder.count
        let handSize = Rules.cardsPerPlayer(players: playerCount)

        let cardsToDeal = playerCount * handSize
        var cardsDealt: Int = 0

        while cardsDealt < cardsToDeal {
            let playerID = gameState.playerOrder[cardsDealt % playerCount]
            try drawCard(playerID: playerID, gameState: &gameState, events: &events)
            cardsDealt += 1
        }
    }

    // MARK: Play Card
    internal static func playCard(
        cardID: Card.ID,
        gameState: inout GameState,
        events: inout [GameEvent]
    ) throws(GameEngineError) {
        // Get card via Card ID and CardStore
        let card = gameState.cardStore[cardID]
        let currentPlayerID = gameState.currentPlayerID

        // Card is removed from hand, irrelevant whether it can be played
        try removeCardFromHand(
            cardID: cardID,
            playerID: currentPlayerID,
            gameState: &gameState
        )

        let cardWasPlayed = addCardToTableauIfPlayable(
            card: card,
            playerID: currentPlayerID,
            gameState: &gameState,
            events: &events
        )

        if cardWasPlayed {
            // Award a hint if this card completed the stack
            let stackWasCompleted = stackIsComplete(for: card.color, gameState: gameState)
            if stackWasCompleted {
                gainHintIfPossible(gameState: &gameState, events: &events)
            }
        } else {
            // Card is sent to discard pile
            try moveCardToDiscard(
                cardID: cardID,
                playerID: currentPlayerID,
                gameState: &gameState,
                events: &events
            )

            // Life is burned
            loseStrike(gameState: &gameState, events: &events)
        }

        // Player must draw a new card
        try drawCard(playerID: currentPlayerID, gameState: &gameState, events: &events)
    }

    // MARK: Discard
    /// Handles removing the card from the player's hand and adding it to the discard pile
    internal static func discard(
        cardID: Card.ID,
        gameState: inout GameState,
        events: inout [GameEvent]
    ) throws(GameEngineError) {
        let currentPlayerID = gameState.currentPlayerID
        // Card is removed from the player's hand
        try removeCardFromHand(
            cardID: cardID,
            playerID: currentPlayerID,
            gameState: &gameState
        )

        // And sent to discard pile
        try moveCardToDiscard(
            cardID: cardID,
            playerID: currentPlayerID,
            gameState: &gameState,
            events: &events
        )

        // Reward a hint for the discard
        gainHintIfPossible(gameState: &gameState, events: &events)

        // Player must draw a new card
        try drawCard(playerID: currentPlayerID, gameState: &gameState, events: &events)
    }

    // MARK: Give Hint
    internal static func giveHint(
        hint: Hint,
        toPlayerID: Player.ID,
        gameState: inout GameState,
        events: inout [GameEvent]
    ) throws(GameEngineError) {
        guard 0 < gameState.hintTokens else { throw .outOfHintTokens }
        if gameState.currentPlayerID == toPlayerID { throw .attemptedSelfHint(playerID: toPlayerID) }

        // Create an array of IDs for the player's hand where the card matches the type and value of the hint given
        let filteredHandIDs = gameState.hands[toPlayerID, default: []]
            // Get card info via IDs
            .map { gameState.cardStore[$0] }
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
        let addedNewIDs = gameState.knowledgeStore.addAndCheckIDs(
            ids: filteredHandIDs,
            for: kind
        )

        // If all IDs are already in the appropriate store, throw error
        guard addedNewIDs else {
            throw .invalidHint(reason: .noNewInfo)
        }

        // If hint was valid, expend token
        gameState.hintTokens -= 1
        events.append(.hintGiven(hint: hint, toPlayerID: toPlayerID, byPlayerID: gameState.currentPlayerID))
        events.append(.hintTokensSet(gameState.hintTokens))
    }

    internal static func advanceFinalRoundCounterIfNeeded(gameState: inout GameState) {
        guard gameState.isFinalRound else { return }
        guard gameState.finalRoundTurnCounter < gameState.numberOfPlayers else { return }
        gameState.finalRoundTurnCounter += 1
    }

    // MARK: - Helpers
    internal static func removeCardFromHand(
        cardID: Card.ID,
        playerID: Player.ID,
        gameState: inout GameState
    ) throws(GameEngineError) {
        let handContainsCard = gameState.hands[playerID]?.contains(cardID) ?? false
        guard handContainsCard else {
            throw .cardNotInHand(cardID: cardID, playerID: playerID)
        }

        gameState.hands[playerID]?
            .removeAll(where: { $0 == cardID })
    }

    
    /// Attempts to add the card to the tableau and returns whether the play was legal.
    ///
    /// - Parameters:
    ///   - card: The card being played.
    ///   - gameState: The current state of the game.
    /// - Returns: A Bool representing whether the play was legal or not.
    internal static func addCardToTableauIfPlayable(
        card: Card,
        playerID: Player.ID,
        gameState: inout GameState,
        events: inout [GameEvent]
    ) -> Bool {
        // Check if card can be played legally
        let cardIsPlayable = isCardPlayable(
            card: card,
            stackHeight: gameState.stacks[card.color, default: []].count
        )

        if cardIsPlayable {
            // Add the card to the stack
            gameState.stacks[card.color, default: []].append(card.id)
            events.append(.cardPlayed(cardID: card.id, playerID: playerID))
            return true
        } else {
            return false
        }
    }

    /// Determines if a stack is complete by comparing the max card value to the height of the stack
    internal static func stackIsComplete(for color: CardColor, gameState: GameState) -> Bool {
        let highestCardValue = CardNumber.allCases.map(\.rawValue).max()
        let stackHeight = gameState.stacks[color, default: []].count
        return highestCardValue == stackHeight
    }

    internal static func moveCardToDiscard(
        cardID: Card.ID,
        playerID: Player.ID,
        gameState: inout GameState,
        events: inout [GameEvent]
    ) throws(GameEngineError) {
        let inserted = gameState.discardPile.append(cardID).inserted
        if inserted {
            events.append(.cardDiscarded(cardID: cardID, playerID: playerID))
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

    internal static func loseStrike(gameState: inout GameState, events: inout [GameEvent]) {
        gameState.strikes -= 1
        events.append(.strikeLost)
    }

    /// Draws a card for the current player and returns the updated state.
    internal static func drawCard(
        playerID: Player.ID,
        gameState: inout GameState,
        events: inout [GameEvent]
    ) throws(GameEngineError) {
        guard !gameState.deckOrder.isEmpty else { return }

        // Make sure the player's hand is not already full, else throw an error.
        let playerHandSize = gameState.hands[playerID, default: []].count
        let maxHandSize = Rules.cardsPerPlayer(players: gameState.playerOrder.count)
        guard playerHandSize < maxHandSize else {
            throw .exceededHandLimit(playerId: playerID)
        }

        let topCardID = gameState.deckOrder.removeLast()
        gameState.hands[playerID, default: []].append(topCardID)
        events.append(.cardDrawn(cardID: topCardID, playerID: playerID))

        // Check if this was the last card and we have entered our final round
        if gameState.deckOrder.isEmpty {
            gameState.isFinalRound = true
            events.append(.finalRoundStarted)
        }
    }

    /// Returns a hint token to the players if they do not already have the maximum allowed.
    internal static func gainHintIfPossible(gameState: inout GameState, events: inout [GameEvent]) {
        guard gameState.hintTokens < Rules.maxHints else { return }
        gameState.hintTokens += 1
        events.append(.hintTokensSet(gameState.hintTokens))
    }

    // MARK: - History
    internal static func appendHistory(
        for action: GameAction,
        playerID: Player.ID,
        events: [GameEvent],
        gameState: inout GameState
    ) {
        gameState.turnRecord.append(
            TurnRecord(
                playerID: playerID,
                action: action,
                events: events
            )
        )
    }
}
