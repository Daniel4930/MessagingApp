//
//  AccountSettingView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/4/25.
//

import SwiftUI

struct AccountSettingView: View {
    @State private var showDeleteAccountAlert = false
    @StateObject private var viewModel = AccountSettingViewModel()
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var alertMessageViewModel: AlertMessageViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            settingTopBar
            
            List {
                userEmailView
                
                editUsernameNavView
                
                logoutButtonView
                
                deleteAccountButtonView
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .tint(.white)
            
            Spacer()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - View components
extension AccountSettingView {
    var userEmailView: some View {
        Text("Email: \(user.email)")
    }
    
    var editUsernameNavView: some View {
        NavigationLink(destination: EditUsernameView()) {
            Text("Username: \(user.userName)")
        }
    }
    
    var logoutButtonView: some View {
        Section {
            Button("Log out", role: .destructive) {
                Task {
                    await viewModel.logout(
                        userViewModel: userViewModel,
                        alertMessageViewModel: alertMessageViewModel
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    var deleteAccountButtonView: some View {
        Section {
            Button("Delete account", role: .destructive) {
                showDeleteAccountAlert.toggle()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .alert("Delete account", isPresented: $showDeleteAccountAlert) {
                deleteAccountAlertView
            } message: {
                Text("Your account will be permanently deleted. To continue with this action, please enter your password.")
            }
        }
    }
    
    var deleteAccountAlertView: some View {
        VStack {
            TextField("Enter password", text: $viewModel.password, prompt: Text("Enter your password"))
            
            HStack {
                Button("Confirm", role: .destructive) {
                    Task {
                        await viewModel.deleteAccount(
                            user: user,
                            alertMessageViewModel: alertMessageViewModel
                        )
                    }
                }
                
                Button("Close", role: .cancel) {
                    showDeleteAccountAlert = false
                }
            }
        }
    }
    
    var settingTopBar: some View {
        ZStack {
            HStack {
                Button(action: { dismiss() }) {
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

// MARK: - View computed properties
extension AccountSettingView {
    var user: User {
        guard let user = userViewModel.user else {
            fatalError("User infomation is missing")
        }
        return user
    }
}
