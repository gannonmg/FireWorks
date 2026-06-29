//
//  GameRepositoryError.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/26/26.
//

import Foundation

enum GameRepositoryError: Error {
    case gameNotFound(id: GameID)

    var localizedDescription: String {
        switch self {
        case .gameNotFound(let id):
            "Could not find game with ID: \(id)"
        }
    }
}
