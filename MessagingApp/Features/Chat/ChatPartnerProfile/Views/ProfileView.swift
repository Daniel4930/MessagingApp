//
//  ProfileView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/21/25.
//

import SwiftUI

struct ProfileView: View {
    let user: User
    
    @State private var showOptions: Bool = false
    @State private var viewMinYPosition: CGFloat = .zero
    @State private var profileIconMidYPosition: CGFloat = .zero
    @State private var disableScroll = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LineIndicator()
                    .padding(.top, 5)
                
                Button(action: optionButtonAction) {
                    optionButtonLabel
                }
                .modifier(OptionButtonViewModifier())
                .modifier(TapGestureAnimation())
                
                userInfoSection
            }
            .modifier(ProfileBannerColorViewModifier(
                user: user,
                profileIconMidYPosition: $profileIconMidYPosition,
                viewMinYPosition: $viewMinYPosition
            ))

            ProfileAboutMeView(user: user)
                .padding(.horizontal)
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newY in
            scrollGeometryChangeAction(newY: newY)
        }
        .modifier(ProfileContentViewModifier(
            disableScroll: $disableScroll,
            showOptions: $showOptions
        ))
    }
}

// MARK: - View Components
private extension ProfileView {
    func userNameView(displayNameIsEmpty: Bool) -> some View {
        Text(user.userName)
            .font(displayNameIsEmpty ? .title2 : .body)
            .bold(displayNameIsEmpty)
    }
    
    func displayNameView(displayNameIsEmpty: Bool) -> some View {
        if !displayNameIsEmpty {
            return AnyView(
                Text(user.displayName)
                .font(.title2)
                .bold()
            )
        }
        return AnyView(EmptyView())
    }
    
    var userInfoSection: some View {
        let displayNameIsEmpty = user.displayName.isEmpty
        
        return AnyView(
            VStack(alignment: .leading, spacing: 0) {
                UserIconView(
                    urlString: user.icon,
                    iconDimension: CGSize(width: 100, height: 100),
                    borderColor: Color("PrimaryBackgroundColor"),
                    borderWidth: 5
                )
                .modifier(ProfileIconFrameReader(iconMidY: $profileIconMidYPosition))
                .modifier(ProfileOnlineStatusViewModifier(user: user))
                
                displayNameView(displayNameIsEmpty: displayNameIsEmpty)
                
                userNameView(displayNameIsEmpty: displayNameIsEmpty)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        )
    }
    
    var optionButtonLabel: some View {
        Image(systemName: "ellipsis")
            .frame(width: 35, height: 35)
            .contentShape(Rectangle())
            .popover(isPresented: $showOptions, arrowEdge: .top) {
                ProfileOptionsView(user: user, showOptions: $showOptions)
            }
    }
}

// View actions
extension ProfileView {
    func optionButtonAction() {
        showOptions.toggle()
    }
    
    func scrollGeometryChangeAction(newY: CGFloat) {
        if newY < 0 {
            disableScroll = true
        } else {
            disableScroll = false
        }
    }
}
