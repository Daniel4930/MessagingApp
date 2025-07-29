//
//  MessagingAppApp.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

@main
struct MessagingAppApp: App {
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var messageViewModel = MessageViewModel()
    @StateObject private var keyboardProvider = KeyboardProvider()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userViewModel)
                .environmentObject(messageViewModel)
                .environmentObject(keyboardProvider)
        }
    }
}
