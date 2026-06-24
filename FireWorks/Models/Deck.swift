//
//  Deck.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/23/26.
//

import Foundation

typealias Deck = [Card]

extension Deck {
    static func makeDeck() -> Deck {
        CardColor.allCases
            .flatMap { makeCardsForColor($0) }
    }

    private static func makeCardsForColor(_ color: CardColor) -> [Card] {
        CardNumber.allCases
            .flatMap { makeCardsForColorAndNumber(color: color, number: $0) }
    }

    private static func makeCardsForColorAndNumber(
        color: CardColor,
        number: CardNumber
    ) -> [Card] {
        (0..<number.amountPerColor)
            .map { Card(color: color, number: number, instance: $0) }
    }
}

// TODO: Move to testing
extension Deck {
    /// Returns true if all cards in the deck have unique IDs
    func hasUniqueIDs() -> Bool {
        var seen = Set<Card.ID>()
        for card in self {
            if !seen.insert(card.id).inserted { return false }
        }
        return true
    }

    /// Returns any duplicated IDs found in the deck (empty if none)
    func duplicateIDs() -> [Card.ID] {
        var seen = Set<Card.ID>()
        var duplicates = Set<Card.ID>()
        for card in self {
            let result = seen.insert(card.id)
            if !result.inserted {
                duplicates.insert(result.memberAfterInsert)
            }
        }
        return Array<Card.ID>(duplicates)
    }
}
