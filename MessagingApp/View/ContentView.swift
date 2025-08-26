//
//  ContentView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

enum CurrentView {
    case login
    case content
    case newUser
}

struct ContentView: View {
    @State private var currentView: CurrentView = .login
    
    var body: some View {
        switch currentView {
        case .login:
            LoginView(currentView: $currentView)
        case .content:
            TabsView()
        case .newUser:
            NewUserView(currentView: $currentView)
        }
    }
}

