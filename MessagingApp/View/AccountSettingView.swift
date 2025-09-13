//
//  AccountSettingView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/4/25.
//

import SwiftUI

struct AccountSettingView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            settingTopBar()
            
            if let user = userViewModel.user {
                List {
                    Text("Email: \(user.email)")
                    
                    NavigationLink {
                        EditUsernameView()
                    } label: {
                        Text("Username: \(user.userName)")
                    }
                    
                    // Logout button inside the list
                    Section {
                        Button("Log out", role: .destructive) {
                            Task {
                                await userViewModel.clearFCMToken()
                                do {
                                    try FirebaseAuthService.shared.signOut()
                                    UserDefaults.standard.removeObject(forKey: "email")
                                    NotificationCenter.default.post(name: .didLogOut, object: nil)
                                } catch {
                                    alertMessageViewModel.presentAlert(message: "Failed to sign out: \(error.localizedDescription)", type: .error)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.black)
                .tint(.white)
            }
            Spacer()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
extension AccountSettingView {
    func settingTopBar() -> some View {
        return ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("+")
                        .foregroundStyle(.white)
                        .font(.system(size: 40))
                        .rotationEffect(.degrees(45))
                }
                .modifier(TapGestureAnimation())
                
                Spacer()
            }
            
            Text("Account")
                .font(.title2.bold())
                .foregroundStyle(.white)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}
