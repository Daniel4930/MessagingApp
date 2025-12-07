//
//  NavigationTopBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.
//

import SwiftUI

struct NavigationTopBar: View {
    @Binding var showFileAndImageSelector: Bool
    @EnvironmentObject var friendViewModel: FriendViewModel
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: NavigationTopBarViewModel
    
    init(channelInfo: Channel, showFileAndImageSelector: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: NavigationTopBarViewModel(channelInfo: channelInfo))
        _showFileAndImageSelector = showFileAndImageSelector
    }
    
    var body: some View {
        HStack {
            backButton
            userInfoSection
        }
    }
}

// MARK: - View Components
extension NavigationTopBar {
    private var backButton: some View {
        Button(action: handleBackButtonTap) {
            Image(systemName: "arrow.left")
                .resizable()
                .modifier(NavigationTopBarBackButtonModifier())
        }
    }
    
    private var userInfoSection: some View {
        HStack {
            userInfoView()
        }
    }
    
    private func userInfoView() -> some View {
        if !viewModel.hasMemberIds() {
            AnyView(Text("Unable to get user information"))
        } else if let friend = viewModel.getFriendInfo(friendViewModel: friendViewModel) {
            AnyView(FriendInfoView(friend: friend, viewModel: viewModel))
        } else {
            AnyView(EmptyView())
        }
    }
    
    private func handleBackButtonTap() {
        showFileAndImageSelector = false
        dismiss()
    }
}

// MARK: - Friend Info View
private struct FriendInfoView: View {
    let friend: User
    let viewModel: NavigationTopBarViewModel
    
    var body: some View {
        UserIconView(urlString: friend.icon)
            .overlay(alignment: .bottomTrailing) {
                OnlineStatusCircle(
                    status: friend.onlineStatus.rawValue,
                    color: Color("PrimaryBackgroundColor")
                )
            }
        
        Text(viewModel.getDisplayName(for: friend))
            .modifier(NavigationTopBarUserInfoModifier())
        
        Image(systemName: "chevron.right")
            .resizable()
            .modifier(NavigationTopBarChevronModifier())
    }
}
