//
//  MessageCenter.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/21/25.
//

import SwiftUI

struct MessageCenter: View {
    @State private var selectedFriend: UserInfo?
    @State private var selectedIcon: UserInfo?
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var navViewModel: CustomNavigationViewModel
    
    var body: some View {
        VStack {
            Text("Messages")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .center) {
                Button {
                    print("Search")
                } label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(8)
                        .background(Color.buttonBackground)
                        .clipShape(.circle)
                }
                
                Button {
                    print("Add friends")
                } label: {
                    HStack {
                        Image(systemName: "person.fill.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Add Friends")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.buttonBackground)
                    .clipShape(.capsule)
                }
            }
            .bold()
            .foregroundStyle(.button)
            
            ScrollView {
                ScrollView([.horizontal]) {
                    HStack(spacing: 16) {
                        ForEach(friendViewModel.friends) { friend in
                            Button {
                                selectedIcon = friend
                            } label: {
                                UserIconView(user: friend, iconDimension: .init(width: 45, height: 45))
                                    .overlay(alignment: .bottomTrailing) {
                                        OnlineStatusCircle(status: friend.onlineStatus, color: .primaryBackground)
                                    }
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.primaryBackground)
                                    }
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.vertical, 10)
                
                if let currentUser = userViewModel.user {
                    let dmConversations = friendViewModel.friends.compactMap { friend -> (UserInfo, String)? in
                        let commonChannel = friend.channelId.first(where: { currentUser.channelId.contains($0) })
                        if let channelId = commonChannel {
                            return (friend, channelId)
                        }
                        return nil
                    }

                    ForEach(dmConversations, id: \.0.id) { (friend, channelId) in
                        Button {
                            selectedFriend = friend
                            navViewModel.viewToShow = {
                                AnyView(
                                    DirectMessageView()
                                )
                            }
                        } label: {
                            HStack {
                                UserIconView(user: friend)
                                    .overlay(alignment: .bottomTrailing) {
                                        OnlineStatusCircle(status: friend.onlineStatus, color: .secondaryBackground)
                                    }
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        Text(friend.displayName)
                                            .font(.subheadline)
                                            .bold()
                                        Spacer()
                                        if let lastMessageDate = channelViewModel.channels[channelId]?.date {
                                            Text(lastMessageDate, style: .time)
                                                .font(.footnote)
                                        }
                                    }
                                    Text(channelViewModel.channels[channelId]?.text ?? "No messages yet")
                                        .font(.footnote)
                                        .lineLimit(1)
                                }
                                .opacity(selectedFriend?.id == friend.id ? 1 : 0.4)
                            }
                            .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedFriend?.id == friend.id ? .white.opacity(0.1) : .clear)
                            }
                        }
                        .tint(.white)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            if let friend = friendViewModel.friends.first {
                selectedFriend = friend
                navViewModel.viewToShow = {
                    AnyView(DirectMessageView())
                }
            }
        }
        .sheet(item: $selectedIcon) { friend in
            ProfileView(user: friend)
                .presentationDetents([.fraction(0.95)])
        }
    }
}
