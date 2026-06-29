//
//  AppRouter.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/25/26.
//

import SwiftUI

public typealias GameID = GameState.ID

protocol AppRouter: AnyObject {
    associatedtype Route: Hashable

    var path: NavigationPath { get set }
    var presentedSheet: AppSheet? { get set }

    func push(_ route: Route)
    func pop()
    func popToRoot()
    func presentInstructions()
    func dismissSheet()
}

extension AppRouter {
    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func presentInstructions() {
        presentedSheet = .instructions
    }

    func dismissSheet() {
        presentedSheet = nil
    }
}

// MARK: - GameRouter
@Observable
final class GameRouter: AppRouter {
    typealias Route = GameRoute

    var path = NavigationPath()
    var presentedSheet: AppSheet?
}

extension GameRouter {
    func showGameList() { push(.gameList) }
    func startNewGame() { push(.newGame) }
    func showGame(gameID: GameID) { push(.gameBoard(gameID)) }
}
