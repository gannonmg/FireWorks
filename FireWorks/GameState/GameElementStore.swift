//
//  GameElementStore.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/24/26.
//

import Foundation

public protocol Storable: Hashable, Identifiable, Sendable, Codable where ID: Sendable & Codable {}

/// Stores actual info about the Cards (color and number) and Players (name)
public struct GameElementStore<Element: Storable>: Sendable, Hashable, Codable {

    private let store: [Element.ID: Element]
    let values: [Element]

    init(elements: [Element]) {
        self.values = elements
        self.store = elements.reduce([:]) { partialResult, element in
            var mutableResult = partialResult
            mutableResult[element.id] = element
            return mutableResult
        }
    }

    subscript(_ id: Element.ID) -> Element { store[id]! }

    var count: Int { store.count }
}
