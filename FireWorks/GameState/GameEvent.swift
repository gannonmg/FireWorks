//
//  GameEvent.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/24/26.
//

import Foundation

// What happens as a result of a valid player action
public enum GameEvent: Hashable, Sendable, Codable {
    case cardDrawn(cardID: Card.ID, playerID: Player.ID)
    case cardPlayed(cardID: Card.ID, playerID: Player.ID)
    case cardDiscarded(cardID: Card.ID, playerID: Player.ID)
    case hintGiven(hint: Hint, toPlayerID: Player.ID, byPlayerID: Player.ID)
    case hintTokensSet(Int)
    case strikeLost
    case finalRoundStarted
    case turnAdvanced
    case gameEnded
}
