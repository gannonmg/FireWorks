//
//  NewGameView.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/25/26.
//

import SwiftUI

@Observable
final class NewGameViewModel {
    var playerNames: [String] = ["", ""]

    var removeIsDisabled: Bool { playerNames.count <= Rules.minPlayers }
    var addIsDisabled: Bool { playerNames.count >= Rules.maxPlayers }

    private func makePlayers() -> [Player] {
        playerNames.enumerated()
            .map { enumeration in
                let rawName = enumeration.element
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return rawName.isEmpty ? "Player \(enumeration.offset+1)" : rawName
            }
            .map { Player(displayName: $0) }
    }

    func makeNewGameConfig() -> NewGameConfig {
        let players = makePlayers()
        return NewGameConfig(players: players)
    }
}

struct NewGameView: View {

    @Environment(GameRouter.self) private var gameRouter
    @Environment(GameRepository.self) private var gameStore

    @State private var viewModel = NewGameViewModel()

    var body: some View {
        VStack {
            Text("🎇🎆 Fireworks 🎆🎇")
                .font(.largeTitle.bold())
                .padding(.bottom, 20)

            Text("Start a new game!")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title2.bold())

            ForEach($viewModel.playerNames.indices, id: \.self) { index in
                TextField("Player \(index+1)",
                          text: $viewModel.playerNames[index])
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Button("Remove Player") {
                    viewModel.playerNames.removeLast()
                }
                .buttonStyle(.glass)
                .disabled(viewModel.removeIsDisabled)

                Button("Add Player") {
                    viewModel.playerNames.append("")
                }
                .buttonStyle(.glassProminent)
                .disabled(viewModel.addIsDisabled)
            }

            Spacer()

            Button("Start Game", action: startGame)
        }
        .navigationTitle("New Game")
        .padding(.horizontal)
        .padding(.top, 40)
    }

    private func startGame() {
        Task {
            let config = viewModel.makeNewGameConfig()
            do {
                let newGame = try await gameStore.createGame(config: config)
                gameRouter.push(.gameBoard(newGame.id))
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    @Previewable @State var router = GameRouter()

    NavigationStack(path: $router.path) {
        NewGameView()
            .environment(router)
            .environment(GameRepository(storage: MockGameStorage()))
    }
}
