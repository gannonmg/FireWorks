//
//  Player.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/23/26.
//

import Foundation

public struct Player: Storable {
    public private(set) var id = UUID()
    public let displayName: String
}
