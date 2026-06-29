//
//  HandView.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/26/26.
//

import SwiftUI

struct HandView: View {

    let player: Player
    let hand: [Card]

    var body: some View {
        VStack {
            Text(player.displayName)
                .font(.headline)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            HStack {
                ForEach(hand) { card in
                    PlayerCardView(playerCard: .init(
                        card: card,
                        showColor: true,
                        showNumber: true)
                    )
                        .shadow(radius: 2, x: 1.5, y: 1.5)
                        .frame(maxHeight: 100)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                        .border(.red)
                }
            }
            .border(.black)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.playMat)
                .shadow(radius: 2, x: 1.5, y: 1.5)
        )
    }
}

#Preview {
    VStack {
        HandView(
            player: .init(displayName: "Matt"),
            hand: [
                .init(color: .red, number: .one, instance: 1),
                .init(color: .blue, number: .two, instance: 1),
                .init(color: .green, number: .four, instance: 1),
                .init(color: .green, number: .four, instance: 2)
            ]
        )
        HandView(
            player: .init(displayName: "Matt"),
            hand: [
                .init(color: .red, number: .one, instance: 1),
                .init(color: .blue, number: .two, instance: 1),
                .init(color: .green, number: .four, instance: 2),
                .init(color: .purple, number: .four, instance: 1),
                .init(color: .green, number: .four, instance: 1)
            ]
        )
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.primaryBackground)
}
