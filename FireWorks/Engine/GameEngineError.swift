//
//  GameEngineError.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/24/26.
//

public enum GameEngineError: Error {
    case invalidHint(reason: InvalidHintReason)
    case exceededHandLimit(playerId: Player.ID)
    case cardNotInHand(cardID: Card.ID, playerID: Player.ID)
    /// thrown when a card that already exists in the discard pile is attempted to be added again.
    case illegalDiscard(cardID: Card.ID)
    case outOfHintTokens
    case attemptedSelfHint(playerID: Player.ID)
}

public enum InvalidHintReason: Hashable, Sendable {
    case noMatchingCard
    case noNewInfo
}
