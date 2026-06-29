//
//  GameBoardView.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/26/26.
//

import SwiftUI

struct GameBoardView: View {

    @State var session: GameSession
    var gameState: GameState { session.gameState }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                DeckView(cards: session.deckCards)
            }

            Spacer()

            ForEach(gameState.playerStore.values) { player in
                HandView(
                    player: player,
                    hand: session.hand(for: player)
                )
            }

            Spacer()

            if let error = session.sessionError {
                Text(error.localizedDescription)
            }

            HStack {
                Button("Deal") {
                    withAnimation {
                        session.dealCards()
                    }
                }
                Button("Draw") {
                    withAnimation {
                        session.dealCards()
                    }
                }
            }
            .buttonStyle(.glass)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.primaryBackground)
    }
}

#Preview {
    @Previewable @State var gameSession = GameSession(
        gameState: GameState(players: [
            .init(displayName: "Matt"),
            .init(displayName: "Greg"),
            .init(displayName: "Brett"),
            .init(displayName: "Ashwin")
        ])
    )

    GameBoardView(session: gameSession)
}
