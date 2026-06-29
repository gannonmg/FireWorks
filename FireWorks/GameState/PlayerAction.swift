//
//  GameAction.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/23/26.
//

import Foundation

// What a player submits on their turn
public enum GameAction: Hashable, Sendable, Codable {
    case dealCards
    case play(cardID: Card.ID)
    case discard(cardID: Card.ID)
    case giveHint(hint: Hint, toPlayerID: Player.ID)
}

