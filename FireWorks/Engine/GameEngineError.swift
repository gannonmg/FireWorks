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


    var localizedDescription: String {
        switch self {
        case .invalidHint(let reason):
            "Invalid Hint: \(String(describing: reason))"
        case .exceededHandLimit(let playerId):
            "Player Exceeded Hand Limit - ID \(playerId)"
        case .cardNotInHand(let cardID, let playerID):
            "Attempted to play card not in hand. CardID: \(cardID). PlayerID: \(playerID)"
        case .illegalDiscard(let cardID):
            "Attempted to discard a card that already existed in the discard pile. CardID: \(cardID)"
        case .outOfHintTokens:
            "Attempted to give a hint when no hints remained."
        case .attemptedSelfHint(let playerID):
            "Attempted to give a hint to the current player \(playerID)"
        }
    }
}

public enum InvalidHintReason: Hashable, Sendable {
    case noMatchingCard
    case noNewInfo
}
