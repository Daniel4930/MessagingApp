//
//  MessagingAppApp.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
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
    @StateObject private var notificationViewModel = NotificationViewModel()
    @StateObject private var alertMessageViewModel = AlertMessageViewModel()
    @StateObject private var appStateViewModel = AppStateViewModel()
    
    @State private var appStateId = UUID()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userViewModel)
                .environmentObject(friendViewModel)
                .environmentObject(messageViewModel)
                .environmentObject(channelViewModel)
                .environmentObject(keyboardProvider)
                .environmentObject(notificationViewModel)
                .environmentObject(alertMessageViewModel)
                .environmentObject(appStateViewModel)
                .id(appStateId)
                .onReceive(NotificationCenter.default.publisher(for: .didLogOut)) { _ in
                    appStateId = UUID()
                }
        }
    }
}

// MARK - Messaging delegate
extension AppDelegate: MessagingDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken {
            let dataDict: [String: String] = ["token": fcmToken]
            NotificationCenter.default.post(
                name: Notification.Name("FCMToken"),
                object: nil,
                userInfo: dataDict
            )
        }
    }
}


//MARK - NotificationContent delegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        
        NotificationCenter.default.post(
            name: Notification.Name("didReceiveRemoteNotification"),
            object: nil,
            userInfo: content.userInfo
        )
        
        completionHandler()
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        
    }
}
