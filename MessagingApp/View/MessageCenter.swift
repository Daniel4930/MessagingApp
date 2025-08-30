//
//  MessageCenter.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/21/25.
//

import SwiftUI

struct MessageCenter: View {
    @State private var selectedDmChannel: Channel?
    @State private var selectedFriendIcon: User?
    @State private var showSearchUser = false
    @State private var showAddFriend = false
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
                    showAddFriend = true
                    navViewModel.exitSwipeAction = {
                        showAddFriend = false
                    }
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
                        ForEach(friendViewModel.friends, id: \.id) { friend in
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
                
                ForEach(channelViewModel.dmChannelsMapWithFriends, id: \.friend.id) { map in
                    let friend = map.friend
                    let channel = map.channel
                    let latestMessage = channel.lastMessage
                    
                    Button {
                        selectedDmChannel = channel
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
                                let displayName = friend.displayName
                                let userName = friend.userName
                                let nameToShow = displayName.isEmpty ? userName : displayName
                                
                                if let latestMessage = latestMessage, let text = latestMessage.text {
                                    HStack {
                                        Text(nameToShow)
                                            .font(.subheadline)
                                            .bold()
                                        Spacer()
                                        Text(channelViewModel.formatLastMessageTime(time: latestMessage.timestamp.dateValue()))
                                            .font(.footnote)
                                    }
                                    Text("\(latestMessage.senderId == friend.id ? nameToShow : "You"): \(text)")
                                        .font(.footnote)
                                        .lineLimit(1)
                                } else {
                                    Text(nameToShow)
                                        .font(.subheadline)
                                        .bold()
                                }
                            }
                            .opacity(selectedDmChannel?.id == channel.id ? 1 : 0.4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedDmChannel?.id == channel.id ? .white.opacity(0.1) : .clear)
                        }
                    }
                    .tint(.white)
                }
            }
        }
        .padding()
        .task {
            guard let currentUser = userViewModel.user, let userId = currentUser.id else { return }
            channelViewModel.listenForChannels(userId: userId, friends: friendViewModel.friends)
        }
        .onAppear {
            selectedDmChannel = channelViewModel.dmChannelsMapWithFriends.first?.channel
        }
        .onChange(of: channelViewModel.dmChannelsMapWithFriends) { oldMap, newMap in
            if selectedDmChannel == nil, let first = newMap.first {
                selectedDmChannel = first.channel
                navViewModel.viewToShow = {
                    AnyView(DirectMessageView(channelInfo: first.channel))
                }
            }
        }
        .onChange(of: showAddFriend) { oldValue, newValue in
            if newValue {
                navViewModel.viewToShow = {
                    AnyView(AddFriendView(showAddFriend: $showAddFriend))
                }
                navViewModel.showView()
            } else {
                if let selectedDmChannel {
                    navViewModel.hideView()
                    navViewModel.viewToShow = {
                        AnyView(DirectMessageView(channelInfo: selectedDmChannel))
                    }
                }
            }
        }
        .sheet(item: $selectedFriendIcon) { friend in
            ProfileView(user: friend)
                .presentationDetents([.fraction(0.95)])
        }
    }
}
