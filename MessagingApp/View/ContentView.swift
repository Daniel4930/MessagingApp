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
    @State private var isLoading = true
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        switch currentView {
        case .login:
            LoginView(currentView: $currentView)
            
        case .content:
            if userViewModel.userIcon == nil {
                ProgressView("Loading...")
                    .task {
                        await userViewModel.fetchUserIcon()
                    }
            } else {
                TabsView()
            }
            
        case .newUser:
            NewUserView(currentView: $currentView)
        }
    }
}

