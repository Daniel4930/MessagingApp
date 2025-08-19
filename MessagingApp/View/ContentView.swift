//
//  ContentView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

enum Tabs {
    case login
    case home
}

struct ContentView: View {
    @State private var currentView: Tabs = .login
    
    var body: some View {
        switch currentView {
        case .login:
            LoginView(currentView: $currentView)
        case .home:
            HomeView()
        }
    }
}
