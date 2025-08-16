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
