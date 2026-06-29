//
//  PlayerCardView.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/23/26.
//

import SwiftUI

enum CardLayout {
    static let defaultHeight: CGFloat = 120

    /// 5:7. The standard ratio of a playing card
    static let ratio: CGFloat = 5 / 7
    static let cornerRadius: CGFloat = 16
    static let borderWidth: CGFloat = 3

    static let borderPadding: CGFloat = { _borderPadding + (borderWidth / 2) }()
    private static let _borderPadding: CGFloat = 4

    static let textPadding: CGFloat = { _borderPadding + borderWidth + _textPadding }()
    private static let _textPadding: CGFloat = 6
}


struct PlayerCardView: View {

    // MARK: Properties
    var numberString: String {
        if playerCard.showNumber {
            "\(card.number.rawValue)"
        } else {
            "?"
        }
    }

    var borderColor: Color {
        playerCard.showColor ? card.color.color : .white
    }

    var emoji: String {
        playerCard.showColor ? card.color.emoji : "⁇"
    }

    // MARK: Init
    let playerCard: PlayerCard
    private let card: Card

    init(playerCard: PlayerCard) {
        self.playerCard = playerCard
        self.card = playerCard.card
    }

    // MARK: Body
    var body: some View {
        CardBaseView(
            surfaceColor: .cardSurface,
            borderColor: borderColor
        )
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 2) {
                Text(numberString)
                    .foregroundStyle(borderColor)
                    .font(.title.bold())
            }
            .padding([.top, .trailing], CardLayout.textPadding)
        }
        .overlay(alignment: .bottom) {
            Text(emoji)
                .font(.title.bold())
                .foregroundStyle(borderColor)
                .padding(.bottom, CardLayout.textPadding)
        }
    }
}

struct CardBackView: View {
    var body: some View {
        CardBaseView(
            surfaceColor: .primaryBackground,
            borderColor: .accent
        )
        .overlay {
            Text("🎆")
                .font(.system(size: 40))
                .shadow(radius: 1)
        }
    }
}

struct CardBaseView: View {

    let surfaceColor: Color
    let borderColor: Color

    var body: some View {
        RoundedRectangle(cornerRadius: CardLayout.cornerRadius)
            .shadow(color: .accent.opacity(0.3),
                    radius: 2, x: 1, y: 1)
            .foregroundStyle(surfaceColor)
            .aspectRatio(CardLayout.ratio, contentMode: .fit)
            .overlay(
                ConcentricRectangle()
                    .stroke(borderColor, lineWidth: CardLayout.borderWidth)
                    .padding(CardLayout.borderPadding)
                    .containerShape(
                        .rect(cornerRadius: CardLayout.cornerRadius)
                    )
            )
    }
}

#Preview {
    VStack {
        HStack(spacing: 4) {
            ForEach(CardColor.allCases.enumerated(), id: \.offset) { value in
                let color = value.element
                PlayerCardView(
                    playerCard: .init(
                        card: .init(color: color, number: .four, instance: 0),
                        showColor: value.offset != 1,
                        showNumber: value.offset != 2
                    )
                )
            }
        }
        .padding()

//        PlayerCardView(
//            playerCard: .init(
//                card: .init(color: .red, number: .four, instance: 0),
//                showColor: true,
//                showNumber: true
//            )
//        )

        CardBackView()
            .frame(maxHeight: CardLayout.defaultHeight)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.playMat)
}
