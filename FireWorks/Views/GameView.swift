//
//  GameView.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/24/26.
//

import SwiftUI

struct GameView: View {

    @State private var session: GameSession

    init(session: GameSession) {
        self.session = session
    }

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//#Preview {
//    GameView()
//}
