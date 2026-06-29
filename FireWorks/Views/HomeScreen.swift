//
//  HomeScreen.swift
//  FireWorks
//
//  Created by Matt Gannon on 6/25/26.
//

import SwiftUI

struct HomeScreen: View {

    @State private var currentTab: AppTab = .home

    var body: some View {
        TabView(selection: $currentTab) {
            Tab(value: .home) {
                GameNavigationView()
            } label: {
                Image(systemName: "puzzlepiece")
            }

            Tab(value: .profiile) {
                Text("Profile View")
            } label: {
                Image(systemName: "person")
            }

        }
    }
}
