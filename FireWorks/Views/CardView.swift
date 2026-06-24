//
//  CardView.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/23/26.
//

import SwiftUI

struct CardView: View {

    private enum Layout {
        /// 5:7. The standard ratio of a playing card
        static let ratio: CGFloat = 5 / 7
        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 3

        static let borderPadding: CGFloat = { _borderPadding + (borderWidth / 2) }()
        private static let _borderPadding: CGFloat = 4

        static let textPadding: CGFloat = { _borderPadding + borderWidth + _textPadding }()
        private static let _textPadding: CGFloat = 6
    }

    var numberString: String { "\(card.number.rawValue)" }
    var foregroundColor: Color { card.color.color }

    let card: Card

    var body: some View {
        RoundedRectangle(cornerRadius: Layout.cornerRadius)
            .foregroundStyle(.black.opacity(0.85))
            .aspectRatio(Layout.ratio, contentMode: .fit)
            .overlay(
                ConcentricRectangle()
                    .stroke(foregroundColor, lineWidth: Layout.borderWidth)
                    .padding(Layout.borderPadding)
                    .containerShape(
                        .rect(cornerRadius: Layout.cornerRadius)
                    )
            )
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 2) {
                    Text(numberString)
                        .foregroundStyle(foregroundColor)
                        .font(.title.bold())
                }
                .padding([.top, .trailing], Layout.textPadding)
            }
            .overlay(alignment: .bottom) {
                Text(card.color.emoji)
                    .font(.title.bold())
                    .padding(.bottom, Layout.textPadding)
            }
            .frame(maxWidth: 80)
    }
}

#Preview {
    HStack(spacing: 4) {
        ForEach(CardColor.allCases, id: \.self) { color in
            CardView(card: .init(color: color, number: .four))
        }
    }
    .padding()
}
