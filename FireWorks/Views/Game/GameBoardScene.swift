//
//  GameBoardScene.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/26/26.
//

import SwiftUI

/// Accepts a `GameID` and handles the async loading of the `GameSession`.
struct GameBoardScene: View {

    private enum BoardState {
        case loading
        case loaded(GameSession)
        case failed(GameStoreError)
    }

    @Environment(GameStore.self) private var gameStore
    @State private var boardState: BoardState = .loading

    let gameID: GameID

    var body: some View {
        Group {
            switch boardState {
            case .loading:
                ProgressView()
            case .loaded(let gameSession):
                GameBoardView(session: gameSession)
            case .failed(let gameStoreError):
                Text("Failed to load game with error: \(gameStoreError.localizedDescription)")
            }
        }
    }
}
