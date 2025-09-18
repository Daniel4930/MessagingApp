//
//  ProfileView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/21/25.
//

import SwiftUI

struct ProfileView: View {
    let user: User
    let popView: () -> Void
    
    @State private var showOptions: Bool = false
    @State private var bannerHeight: CGFloat = .zero
    @State private var disableScroll = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LineIndicator()
                    .padding(.top, 5)
                
                Button {
                    showOptions.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 35, height: 35)
                        .contentShape(Rectangle())
                        .popover(isPresented: $showOptions, arrowEdge: .top) {
                            ProfileOptionsView(user: user, showOptions: $showOptions, popView: popView)
                        }
                }
                .background {
                    Circle().fill(.buttonBackground.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top)
                .padding(.bottom, 40)
                .modifier(TapGestureAnimation())
                
                
                userInfoSection
                    .overlay {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    bannerHeight = proxy.frame(in: .global).minY
                                }
                        }
                    }
            }
            .padding(.horizontal)
            .background(alignment: .top) {
                Color(hex: user.bannerColor)
                    .frame(height: bannerHeight)
            }

            ProfileAboutMeView(user: user)
                .padding(.horizontal)
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newY in
            if newY < 0 {
                disableScroll = true
            } else {
                disableScroll = false
            }
        }
        .scrollDisabled(disableScroll)
        .opacity(showOptions ? 0.3 : 1)
        .defaultScrollAnchor(.top)
        .tint(Color("ButtonColor"))
        .background(Color("PrimaryBackgroundColor"))
    }
}

// MARK: - View Components
private extension ProfileView {
    var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            let displayNameIsEmpty = user.displayName.isEmpty
            
            UserIconView(urlString: user.icon, iconDimension: CGSize(width: 100, height: 100), borderColor: Color("PrimaryBackgroundColor"), borderWidth: 5)
                .overlay(alignment: .bottomTrailing) {
                    OnlineStatusCircle(
                        status: user.onlineStatus.rawValue,
                        color: Color("PrimaryBackgroundColor"),
                        outterDimension: .init(width: 26, height: 26),
                        innerDimension: .init(width: 20, height: 20)
                    )
                    .offset(x: -3, y: -1)
                }
                .padding(.bottom, 10)
            
            if !displayNameIsEmpty {
                Text(user.displayName)
                    .font(.title2)
                    .bold()
            }
            
            Text(user.userName)
                .font(displayNameIsEmpty ? .title2 : .body)
                .bold(displayNameIsEmpty)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ProfileOptionsView: View {
    let user: User
    @Binding var showOptions: Bool
    let popView: () -> Void
    
    @EnvironmentObject var alertViewModel: AlertMessageViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ProfileOptionButton(title: "Copy Username", role: .cancel) {
                let pasteboard = UIPasteboard.general
                pasteboard.string = user.userName
                alertViewModel.presentAlert(message: "Username copied", type: .success)
                showOptions = false
            }
            if let currentUser = userViewModel.user, user.id != currentUser.id, let friendId = user.id {
                ProfileOptionButton(title: "Remove Friend", role: .destructive) {
                    Task {
                        await friendViewModel.removeFriend(for: currentUser, friendId: friendId)
                    }
                    popView()
                }
            }
        }
        .frame(minWidth: 180)
        .presentationCompactAdaptation(.popover)
    }
}

private struct ProfileOptionButton: View {
    let title: String
    let role: ButtonRole
    let action: () -> Void
    
    var body: some View {
        Button(role: role , action: action) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .contentShape(Rectangle())
    }
}

