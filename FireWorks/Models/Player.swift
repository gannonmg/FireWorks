//
//  Player.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/23/26.
//

import Foundation

public struct Player: Identifiable, Hashable, Sendable {
    public let id = UUID()
    var cards: [Card] = []
}
