//
//  Knowledge.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/24/26.
//

import Foundation

/// Tracks whether the color or number of a card has been revealed
public enum Knowledge {
    public enum Kind: Hashable, Sendable, Codable {
        case color, number
    }

    public struct Store: Hashable, Sendable, Codable {
        private var knownColorIDs: Set<Card.ID>
        private var knownNumberIDs: Set<Card.ID>

        public init() {
            self.knownColorIDs = []
            self.knownNumberIDs = []
        }

        public func isKindKnown(for id: Card.ID, kind: Kind) -> Bool {
            switch kind {
            case .color: knownColorIDs.contains(id)
            case .number: knownNumberIDs.contains(id)
            }
        }

        /// Adds given IDs to the appropriate knowledge store. Returns a Boolean representing whether any new insertions occured.
        /// - Parameters:
        ///   - ids: An array of Card IDs to be added to the store.
        ///   - kind: The kind of the store that the IDs are to be added to.
        /// - Returns: A Boolean representing whether any new insertions occured
        public mutating func addAndCheckIDs(ids: [Card.ID], for kind: Kind) -> Bool {
            // Inserts the card ids, and maps partial results to `insertionResults: [Bool]`
            let insertionResults: [Bool] = ids.map {
                switch kind {
                case .color: knownColorIDs.insert($0).inserted
                case .number: knownNumberIDs.insert($0).inserted
                }
            }

            // If `inserted` was false for all IDs, this is not a valid play, as no new information was gained.
            return insertionResults.contains(true)
        }
    }
}
