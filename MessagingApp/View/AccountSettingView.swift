//
//  AccountSettingView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/4/25.
//

import SwiftUI

struct AccountSettingView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navViewModel: CustomNavigationViewModel
    
    var body: some View {
        NavigationStack {
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
                                do {
                                    try FirebaseAuthService.shared.signOut()
                                } catch {
                                    print("Failed to sign out: \(error)")
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
        }
    }
}
extension AccountSettingView {
    func settingTopBar() -> some View {
        return ZStack {
            HStack {
                Button {
                    hideKeyboard()
                    navViewModel.hideView {
                        navViewModel.viewToShow = nil
                    }
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
