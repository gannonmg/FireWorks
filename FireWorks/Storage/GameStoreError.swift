//
//  GameStoreError.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/26/26.
//

import Foundation

enum GameStoreError: Error {
    case gameNotFound(id: GameID)
}
