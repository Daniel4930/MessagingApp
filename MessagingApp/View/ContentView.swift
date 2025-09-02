import SwiftUI
import FirebaseMessaging

enum CurrentView {
    case login
    case content
    case newUser
}

struct ContentView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    
    @State private var currentView: CurrentView = .login
    @State private var isCheckingAuth = true
    
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
            .onAppear(perform: setupFCMTokenObserver)
        }
    }
    
    func attemptAutoLogin() {
        Task {
            guard let (email, password) = KeychainService.shared.load() else {
                isCheckingAuth = false
                return
            }
            
            do {
                let authData = try await FirebaseAuthService.shared.signInAUser(email: email, password: password)
                
                if let email = authData.user.email {
                    await userViewModel.fetchCurrentUser(email: email)
                    
                    if let newToken = try? await Messaging.messaging().token() {
                        if userViewModel.user?.fcmToken != newToken {
                            await userViewModel.updateUserFCMToken(newToken)
                        }
                    }
                }
                
                if let user = userViewModel.user {
                    if user.userName.isEmpty {
                        currentView = .newUser
                    } else {
                        await friendViewModel.fetchFriends(for: user)
                        currentView = .content
                    }
                } else {
                    currentView = .login
                }
                
            } catch {
                // If auto-login fails, clear invalid credentials
                KeychainService.shared.clear(email: email)
                currentView = .login
            }
            
            isCheckingAuth = false
        }
    }
    
    private func setupFCMTokenObserver() {
        NotificationCenter.default.addObserver(forName: Notification.Name("FCMToken"), object: nil, queue: .main) { notification in
            Task { @MainActor in
                guard let newToken = notification.userInfo?["token"] as? String else { return }
                
                // Safely access userViewModel.user and update token if needed
                if userViewModel.user?.fcmToken != newToken {
                    await userViewModel.updateUserFCMToken(newToken)
                }
            }
        }
    }
}
