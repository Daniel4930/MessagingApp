import SwiftUI

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
            switch currentView {
            case .login:
                LoginView(currentView: $currentView)
            case .content:
                TabsView()
            case .newUser:
                NewUserView(currentView: $currentView)
            }
        }
    }
    
    func attemptAutoLogin() {
        guard let (email, password) = KeychainService.shared.load() else {
            isCheckingAuth = false
            return
        }

        FirebaseAuthService.shared.signInAUser(email: email, password: password) { result in
            switch result {
            case .success(let authData):
                Task {
                    if let email = authData.user.email {
                        await userViewModel.fetchCurrentUser(email: email)
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
                    isCheckingAuth = false
                }
            case .failure:
                // Clear invalid credentials from keychain
                KeychainService.shared.clear(email: email)
                isCheckingAuth = false
            }
        }
    }
}