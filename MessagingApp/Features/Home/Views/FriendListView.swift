//
//  FriendListView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/2/25.
//

import SwiftUI

struct FriendListView: View {
    @Binding var selectedDmChannel: Channel?
    
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = FriendListViewModel()
    
    var body: some View {
        NavigationStack {
            friendsList
        }
        .searchable(text: $viewModel.nameToSearch, prompt: Text("Search your friends"))
    }
    
    private var friendsList: some View {
        List {
            ForEach(viewModel.searchResult(friendViewModel: friendViewModel), id: \.self) { friend in
                FriendRowView(
                    friend: friend,
                    listItemWidth: viewModel.listItemWidth,
                    messageAction: { handleMessageAction(for: friend) },
                    removeAction: { handleRemoveAction(for: friend) }
                )
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear { viewModel.updateListItemWidth(proxy.size.width) }
                            .allowsHitTesting(false)
                    }
                }
                .contentShape(Rectangle())
                .buttonStyle(.borderless)
            }
        }
        .modifier(FriendListToolbarModifier(dismissAction: { dismiss() }))
    }
    
    private func handleMessageAction(for friend: User) {
        guard let channel = viewModel.createDMChannel(
            with: friend,
            userViewModel: userViewModel,
            channelViewModel: channelViewModel
        ) else { return }
        selectedDmChannel = channel
        dismiss()
    }
    
    private func handleRemoveAction(for friend: User) {
        Task {
            await viewModel.removeFriend(
                friend,
                userViewModel: userViewModel,
                friendViewModel: friendViewModel
            )
        }
    }
}


// MARK: - Friend Row View
private struct FriendRowView: View {
    let friend: User
    let listItemWidth: CGFloat
    let messageAction: () -> Void
    let removeAction: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            UserIconView(urlString: friend.icon)
            
            friendInfo
            
            Spacer()
            
            actionButtons
        }
    }
    
    private var friendInfo: some View {
        VStack(alignment: .leading) {
            let displayNameIsEmpty = friend.displayName.isEmpty
            
            if !displayNameIsEmpty {
                Text(friend.displayName)
                    .bold()
            }
            Text(friend.userName)
                .font(displayNameIsEmpty ? .body : .footnote)
                .bold(displayNameIsEmpty)
        }
    }
    
    private var actionButtons: some View {
        HStack {
            Button(action: messageAction) {
                Image(systemName: "message.fill")
            }
            .modifier(ListButtonModifier(backgroundColor: .blue, listItemWidth: listItemWidth))
            
            Button(action: removeAction) {
                Image(systemName: "person.fill.badge.minus")
            }
            .modifier(ListButtonModifier(backgroundColor: .red, listItemWidth: listItemWidth))
        }
    }
}
