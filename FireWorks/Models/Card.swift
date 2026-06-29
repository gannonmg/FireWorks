//
//  Card.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/23/26.
//

import Foundation

public struct Card: Storable {
    public let id: String
    public let color: CardColor
    public let number: CardNumber

    init(color: CardColor, number: CardNumber, instance: Int) {
        // A descriptive string representing the unique card.
        // For example, a Red 5 will always be "red.five.1"
        // However, a Red 1 will be "red.one.#" where # is 1, 2, or 3.
        self.id = "\(String(describing: color)).\(String(describing: number)).\(instance+1)"
        self.color = color
        self.number = number
    }
}
