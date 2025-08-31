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
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var currentView: CurrentView = .login
    
    var body: some View {
//        Group {
            switch currentView {
            case .login:
                LoginView(currentView: $currentView)
            case .content:
                TabsView()
            case .newUser:
                NewUserView(currentView: $currentView)
            }
//        }
//        .onAppear(perform: setupFCMTokenObserver)
    }
    
//    private func setupFCMTokenObserver() {
//        NotificationCenter.default.addObserver(forName: Notification.Name("FCMToken"), object: nil, queue: .main) { notification in
//            if let token = notification.userInfo?["token"] as? String {
//                Task {
//                    await userViewModel.updateUserFCMToken(token)
//                }
//            }
//        }
//    }
}

