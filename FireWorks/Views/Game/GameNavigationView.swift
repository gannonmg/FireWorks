//
//  GameNavigationView.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/25/26.
//

import SwiftUI

struct GameNavigationView: View {

    @State private var gameRouter = GameRouter()
    @State private var gameStore = GameStore(storage: MockGameStorage())

    var body: some View {
        NavigationStack(path: $gameRouter.path) {
            VStack {
                Button(
                    "Continue Game",
                    action: gameRouter.showGameList
                )
                .buttonStyle(.glassProminent)
                .disabled(gameStore.summaries.isEmpty)

                Button(
                    "New Game",
                    action: gameRouter.startNewGame
                )
                .buttonStyle(.glassProminent)
            }
            .navigationTitle("Fireworks 🎆🎇🎆🎇🎆")
            .navigationDestination(for: GameRoute.self) { route in
                switch route {
                case .gameList:
                    Text("Game List")
                case .newGame:
                    NewGameView()
                case .gameBoard(let gameID):
                    GameBoardScene(gameID: gameID)
                }
            }
        }
        .environment(gameRouter)
        .environment(gameStore)
    }
}
