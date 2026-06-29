//
//  GameRoute.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/25/26.
//

import Foundation

enum GameRoute: Hashable {
    case gameList
    case gameBoard(GameID)
    case newGame
}

extension GameRoute {
    static func / (lhs: GameRoute, rhs: GameRoute) -> [GameRoute] {
        return [lhs, rhs]
    }

    static func / (lhs: [GameRoute], rhs: GameRoute) -> [GameRoute] {
        return lhs + [rhs]
    }
}
