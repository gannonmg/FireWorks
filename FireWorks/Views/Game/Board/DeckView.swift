//
//  DeckView.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/26/26.
//

import SwiftUI

struct DeckView: View {
    let cards: [Card]

    var body: some View {
        ZStack {
            ForEach(cards.enumerated(), id: \.element) {
                let card = $0.element
                let index = $0.offset

                let cardOffset = CGFloat(index) * 6

                CardBackView()
                    .id(card.id)
                    .frame(maxHeight: CardLayout.defaultHeight)
                    .offset(x: -cardOffset/2, y: cardOffset)
            }
        }
    }
}

#Preview {
    DeckView(
        cards: Array(Deck.makeDeck().prefix(upTo: 3))
    )
}
