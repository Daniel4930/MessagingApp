//
//  MessagingAppApp.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MessagingAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var friendViewModel = FriendViewModel()
    @StateObject private var messageViewModel = MessageViewModel()
    @StateObject private var keyboardProvider = KeyboardProvider()
    @StateObject private var channelViewModel = ChannelViewModel()
    @StateObject private var navViewModel = CustomNavigationViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userViewModel)
                .environmentObject(friendViewModel)
                .environmentObject(messageViewModel)
                .environmentObject(channelViewModel)
                .environmentObject(keyboardProvider)
                .environmentObject(navViewModel)
        }
    }
}
