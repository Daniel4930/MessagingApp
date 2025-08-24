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
    @StateObject var navViewModel = CustomNavigationViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        switch currentView {
        case .login:
            LoginView(currentView: $currentView)
        case .content:
            TabsView(navViewModel: navViewModel)
                .gesture(
                    DragGesture()
                        .onChanged(navViewModel.onDragChanged(_:))
                        .onEnded(navViewModel.onDragEnded(_:))
                )
        case .newUser:
            NewUserView(currentView: $currentView)
        }
    }
}

