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
    @State private var startingOffset: CGFloat = .zero
    @State private var currentOffset: CGFloat = .zero
    @State private var endingOffset: CGFloat = .zero
    @State private var totalOffset: CGFloat = .zero
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    let threshold: CGFloat = UIScreen.main.bounds.width * 0.5
    let velocityThreshold: CGFloat = 700
    let maxOffset: CGFloat = UIScreen.main.bounds.width
    
    var dragGesture: some Gesture {
         DragGesture()
            .onChanged { value in
                let translation = value.translation.width
                if endingOffset == -maxOffset && translation < 0 { return }
                currentOffset = translation
                totalOffset = startingOffset + currentOffset + endingOffset
            }
            .onEnded { value in
                let velocity = value.velocity.width
                
                withAnimation(.snappy()) {
                    if velocity >= velocityThreshold {
                        currentOffset = maxOffset
                    } else if velocity <= -velocityThreshold {
                        currentOffset = -maxOffset
                    }
                    
                    if currentOffset <= -threshold {
                        endingOffset = -startingOffset
                    } else if currentOffset >= threshold {
                        endingOffset = 0
                    }
                    currentOffset = 0
                    totalOffset = startingOffset + currentOffset + endingOffset
                }
            }
    }
    
    var body: some View {
        switch currentView {
        case .login:
            LoginView(currentView: $currentView)
            
        case .content:
            TabsView(xOffset: $totalOffset)
                .gesture(dragGesture)
                .onAppear {
                    startingOffset = maxOffset
                    totalOffset = startingOffset + currentOffset + endingOffset
                }
            
//            if let user = userViewModel.user, userViewModel.userIcon == nil {
//                ProgressView("Loading...")
//                    .task {
//                        let icon = await userViewModel.fetchIcon(urlString: user.icon)
//                        userViewModel.userIcon = icon
//                    }
//            } else {
//                TabsView(xOffset: $totalOffset)
//                    .gesture(dragGesture)
//                    .onAppear {
//                        startingOffset = maxOffset
//                        totalOffset = startingOffset + currentOffset + endingOffset
//                    }
//            }
            
        case .newUser:
            NewUserView(currentView: $currentView)
        }
    }
}

