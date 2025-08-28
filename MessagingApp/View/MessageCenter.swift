//
//  MessageCenter.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/21/25.
//

import SwiftUI

struct MessageCenter: View {
    @State private var selectedFriend: User?
    @State private var selectedFriendIcon: User?
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
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
                                selectedFriendIcon = friend
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
                
                ForEach(channelViewModel.dmChannelsMapWithFriends) { map in
                    let friend = map.friend
                    let channel = map.channel
                    let latestMessage = channel.lastMessage
                    
                    Button {
                        selectedFriend = friend
                        navViewModel.viewToShow = {
                            AnyView(
                                DirectMessageView(channelInfo: channel)
                            )
                        }
                        navViewModel.showView()
                    } label: {
                        HStack {
                            UserIconView(user: friend)
                                .overlay(alignment: .bottomTrailing) {
                                    OnlineStatusCircle(status: friend.onlineStatus, color: .secondaryBackground)
                                }
                            VStack(alignment: .leading, spacing: 0) {
                                if let latestMessage = latestMessage {
                                    HStack {
                                        Text(friend.displayName)
                                            .font(.subheadline)
                                            .bold()
                                        Spacer()
                                        Text("\(latestMessage.timestamp.dateValue().formatted())")
                                            .font(.footnote)
                                    }
                                    Text(latestMessage.text)
                                        .font(.footnote)
                                        .lineLimit(1)
                                } else {
                                    Text(friend.displayName)
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                }
                            }
                            .opacity(selectedFriend?.id == friend.id ? 1 : 0.4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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
        .padding()
        .task {
            guard let currentUser = userViewModel.user else { return }
            channelViewModel.listenForChannels(userId: currentUser.id!, friends: friendViewModel.friends)
        }
        .onChange(of: channelViewModel.dmChannelsMapWithFriends) { oldMap, newMap in
            if selectedFriend == nil, let first = newMap.first {
                selectedFriend = first.friend
                navViewModel.viewToShow = {
                    AnyView(DirectMessageView(channelInfo: first.channel))
                }
            }
        }
        .sheet(item: $selectedFriendIcon) { friend in
            ProfileView(user: friend)
                .presentationDetents([.fraction(0.95)])
        }
    }
}
