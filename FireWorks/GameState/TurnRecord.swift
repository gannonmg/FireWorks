//
//  TurnRecord.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/24/26.
//

import Foundation

public struct TurnRecord: Hashable, Sendable, Codable {
    public let playerID: Player.ID
    public let action: GameAction
    public let events: [GameEvent]
}
