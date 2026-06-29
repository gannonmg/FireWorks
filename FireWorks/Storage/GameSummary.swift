//
//  GameSummary.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/26/26.
//

import Foundation

struct GameSummary: Identifiable, Hashable, Sendable {
    let id: GameID
    let title: String
    let createdAt: Date
    let lastUpdatedAt: Date
    let isCompleted: Bool
    let playerNames: [String]
}
