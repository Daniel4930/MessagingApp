import SwiftUI
import FirebaseMessaging

struct ContentView: View {
    @State private var currentView: CurrentView = .login
    @State private var isCheckingAuth = true
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
    
    var body: some View {
        if isCheckingAuth {
            ProgressView("Signing In...")
                .onAppear {
                    attemptAutoLogin()
                }
        } else {
            Group {
                switch currentView {
                case .login:
                    LoginView(currentView: $currentView)
                case .content:
                    TabsView()
                case .newUser:
                    NewUserView(currentView: $currentView)
                }
            }
            .onAppear(perform: setupObservers)
            .overlay(alignment: .top) {
                if alertMessageViewModel.showAlert {
                    AlertMessageView()
                }
            }
        }
    }
    
    func attemptAutoLogin() {
        Task {
            //Get user email. If it doesn't exist, return to login screen
            guard let email = UserDefaults.standard.string(forKey: "email") else {
                isCheckingAuth = false
                return
            }
            
            //If user already sign in, fetch user's data
            if FirebaseAuthService.shared.isSignIn(email: email) {
                await userViewModel.fetchCurrentUser(email: email)
                
                //If fetch user failed, show alert and return to login screen
                guard let user = userViewModel.user else {
                    alertMessageViewModel.presentAlert(message: "Failed to auto-login. Please sign in again.", type: .error)
                    isCheckingAuth = false
                    return
                }
                
                //Update FCM token of the user's device for receiving notification if needed
                if let newToken = try? await Messaging.messaging().token() {
                    if user.fcmToken != newToken {
                        await userViewModel.updateUserFCMToken(newToken)
                    }
                }
                
                //If username is empty, show newUser screen to setup user.
                if user.userName.isEmpty {
                    currentView = .newUser
                } else {
                    await friendViewModel.fetchFriends(for: user)
                    currentView = .content
                }
            } else {
                //If the user is not sign in, show login screen
                alertMessageViewModel.presentAlert(message: "Your session has expired. Please sign in again.", type: .info)
            }
            
            isCheckingAuth = false
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: Notification.Name("FCMToken"), object: nil, queue: .main) { notification in
            Task { @MainActor in
                guard let newToken = notification.userInfo?["token"] as? String else { return }
                
                // Safely access userViewModel.user and update token if needed
                if userViewModel.user?.fcmToken != newToken {
                    await userViewModel.updateUserFCMToken(newToken)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: .didLogOut, object: nil, queue: .main) { _ in
            currentView = .login
        }
    }
}
